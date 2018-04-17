//
//  APIServices.swift
//  Myra
//
//  Created by Jason Leach on 2018-04-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Alamofire
import Realm
import RealmSwift

class DataServices: NSObject {
    
    typealias UploadCompleted = () -> Void
    
    internal static let shared = DataServices()
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1 // serial queue
        
        return q
    }()
    internal var onUploadCompleted: UploadCompleted?
    
    override init() {
        super.init()
        
        queue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
    }
    
    static func plan(withLocalId localId: String) -> RUP? {
        guard let realm = try? Realm(), let plan = realm.objects(RUP.self).filter("realmID = %@", localId).first else {
            return nil
        }
        
        return plan
    }
    
    static func pasture(withLocalId localId: String) -> Pasture? {
        guard let pastures = try? Realm().objects(Pasture.self).filter("realmID = %@", localId), let pasture = pastures.first else {
            return nil
        }
        
        return pasture
    }


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath! {
        case "operations":
            if queue.operations.count == 0 {
                onUploadCompleted?()
            }
        default:
            return
        }
    }
    
    internal func uploadDraftRangeUsePlans(completion: @escaping () -> Void) {
        
        guard let agreements = try? Realm().objects(Agreement.self).filter("ANY rups.remoteId == %@", Constants.Defaults.planId), agreements.count > 0 else {
            completion()
            return // no plans to upload
        }
        
        onUploadCompleted = completion
        
        for agreement in agreements {
            let agreementId = agreement.agreementId
            queue.addAsyncOperation { done in
                guard let myAgreements = try? Realm().objects(Agreement.self).filter("agreementId = %@", agreementId), let myAgreement = myAgreements.first else {
                    return
                }
                
                self.uploadPlans(forAgreement: myAgreement) { () in
                    done()
                }
            }
        }
    }
    
    private func uploadPlans(forAgreement agreement: Agreement, completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        for plan in agreement.rups {
            let agreementId = agreement.agreementId
            let planId = plan.localId
            
            group.enter()
            
            // Were on a new thread now !
            guard let myPlan = DataServices.plan(withLocalId: planId) else {
                group.leave()
                return
            }
            
            APIManager.add(plan: myPlan, toAgreement: agreementId, completion: { (response, error) in
                guard let response = response, error == nil else {
                    fatalError()
                }
                
                // Were on a new thread now !
                if let plan = DataServices.plan(withLocalId: planId), let realm = try? Realm() {
                    do {
                        try realm.write {
                            plan.remoteId = response["id"] as! Int
                        }
                        
                        self.uploadPastures(forPlan: plan, completion: {
                            group.leave()
                        })
                    } catch {
                        fatalError() // just for now.
                    }
                }
                
            })
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func uploadPastures(forPlan plan: RUP, completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        for pasture in plan.pastures {
            let pastureId = pasture.realmID
            let planId = "\(plan.remoteId)"
            
            group.enter()
            
            // Were on a new thread now !
            guard let myPasture = DataServices.pasture(withLocalId: pastureId) else {
                group.leave()
                return
            }
            
            APIManager.add(pasture: myPasture, toPlan: planId, completion: { (response, error) in
                guard let response = response, error == nil else {
                    fatalError()
                }
                
                // Were on a new thread now !
                if let pasture = DataServices.pasture(withLocalId: pastureId), let realm = try? Realm() {
                    do {
                        try realm.write {
                            pasture.dbID = response["id"] as! Int
                        }
                        
                        group.leave()
                    } catch {
                        fatalError() // just for now.
                    }
                }
            })
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
