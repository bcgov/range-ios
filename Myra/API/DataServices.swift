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
        
        guard let agreements = try? Realm().objects(Agreement.self).filter("ANY rups.id == %@", Constants.Defaults.planId), agreements.count > 0 else {
            completion()
            return // no plans to upload
        }
        
        onUploadCompleted = completion
        
        for i in agreements.enumerated() {
            for j in i.element.rups.enumerated() {
                // let offset = j.offset
                let plan = j.element
                let pid = plan.realmID
                
                queue.addAsyncOperation { done in
                    
                    // different thread, need new realm to access.
                    guard let plans = try? Realm().objects(RUP.self).filter("realmID = %@", pid), let myPlan = plans.first else {
                        return
                    }
                    
                    APIManager.create(plan: myPlan, completion: { (response, error) in
                        guard let response = response, error == nil else {
                            fatalError()
                        }
                        
                        // different thread again, need new realm to write.
                        if let realm = try? Realm(), let aPlan = realm.objects(RUP.self).filter("realmID = %@", plan.realmID).first {
                            do {
                                try realm.write {
                                    aPlan.id = response["id"] as! Int
                                }
                            } catch {
                                fatalError() // just for now.
                            }
                        }
                        
                        done()
                    })
                }
            }
        }
    }
}
