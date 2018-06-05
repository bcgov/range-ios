//
//  APIServices.swift
//  Myra
//
//  Created by Jason Leach on 2018-04-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Realm
import RealmSwift
import Reachability

class DataServices: NSObject {
    
    typealias UploadCompleted = () -> Void
    
    internal static let shared = DataServices()

    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1 // serial queue
        
        return q
    }()
    internal var onUploadCompleted: UploadCompleted?

    // auto sync vars
    var realmNotificationToken: NotificationToken?
    var isSynchronizing: Bool = false
    
    override init() {
        super.init()
        
        queue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
    }

    func beginAutoSyncListener() {
        print("Listening!")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("change observed")
                self.autoSync()
            }
        } catch _ {
            fatalError()
        }
    }

    func autoSync() {
        guard let r = Reachability() else {return}
        if r.connection == .none {
            print("But you're offline so bye")
            return
        }
        print("You're Online")
//        DispatchQueue.global(qos: .background).async {
            if self.isSynchronizing {return}
            if RUPManager.shared.getOutboxRups().count > 0 {
                print("Upload Outbox now!")
                self.isSynchronizing = true
                self.uploadOutboxRangeUsePlans {
                    print("uploaded outbox alerts")
                    self.isSynchronizing = false
                }
            } else {
                print("But nothing in outbox")
        }
//        }
    }

    func endAutoSyncListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            print("Stopped Listening :(")
        }
    }
    
    static func plan(withLocalId localId: String) -> RUP? {
        guard let realm = try? Realm(), let plan = realm.objects(RUP.self).filter("localId = %@", localId).first else {
            return nil
        }
        
        return plan
    }
    
    static func pasture(withLocalId localId: String) -> Pasture? {
        guard let pastures = try? Realm().objects(Pasture.self).filter("localId = %@", localId), let pasture = pastures.first else {

            return nil
        }
        
        return pasture
    }

    static func ministersIssue(withLocalId localId: String) -> MinisterIssue? {
        guard let issues = try? Realm().objects(MinisterIssue.self).filter("localId = %@", localId), let issue = issues.first else {

            return nil
        }

        return issue
    }

    static func ministersIssueAction(withLocalId localId: String) -> MinisterIssueAction? {
        guard let actions = try? Realm().objects(MinisterIssueAction.self).filter("localId = %@", localId), let action = actions.first else {

            return nil
        }

        return action
    }

    static func schedule(withLocalId localId: String) -> Schedule? {
        guard let schedules = try? Realm().objects(Schedule.self).filter("localId = %@", localId), let schedule = schedules.first else {
            return nil
        }

        return schedule
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

    internal func uploadOutboxRangeUsePlans(completion: @escaping () -> Void) {

        let outboxPlans = RUPManager.shared.getOutboxRups()
//        onUploadCompleted = completion
        self.upload(plans: outboxPlans) {
            return completion()
        }

    }

    private func upload(plans: [RUP], completion: @escaping () -> Void) {

        let group = DispatchGroup()

        for plan in plans {
            let agreementId = plan.agreementId
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
                guard let myPlanAgain = DataServices.plan(withLocalId: planId) else {
                    group.leave()
                    return
                }

                // Were on a new thread now !
                if let realm = try? Realm() {
                    do {
                        try realm.write {
                            myPlanAgain.remoteId = response["id"] as! Int
                        }
                        self.uploadPastures(forPlan: plan, completion: {
                            self.uploadSchedules(forPlan: plan, completion: {
                                self.uploadMinistersIssues(forPlan: plan, completion: {
                                    // Set status to Pending
                                    if plan.statusEnum == .Outbox {
                                        do {
                                            let realm = try Realm()
                                            try realm.write {
                                                plan.statusEnum = .Pending
                                            }
                                        } catch _ {
                                            fatalError()
                                        }
                                    }
                                    group.leave()
                                })
                            })
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
                            self.uploadSchedules(forPlan: plan, completion: {
                                if plan.statusEnum == .Outbox {
                                    do {
                                        let realm = try Realm()
                                        try realm.write {
                                            plan.statusEnum = .Pending
                                        }
                                    } catch _ {
                                        fatalError()
                                    }
                                }
                                 group.leave()
                            })
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

    private func uploadMinistersIssues(forPlan plan: RUP, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for issue in plan.ministerIssues {
            let issueId = issue.localId
            let planId = "\(plan.remoteId)"

            group.enter()

            guard let myIssue = DataServices.ministersIssue(withLocalId: issueId) else {
                group.leave()
                return
            }

            APIManager.add(issue: myIssue, toPlan: planId) { (response, error) in
                guard let response = response, error == nil else {
                    fatalError()
                }

                // Were on a new thread now !
                if let myNewIssue = DataServices.ministersIssue(withLocalId: issueId), let realm = try? Realm() {
                    do {
                        try realm.write {
                            myNewIssue.remoteId = response["id"] as! Int
                        }
                    } catch {
                        fatalError() // just for now.
                    }

                    // Upload actions
                    DataServices.shared.uploadMinistersIssueActions(forIssue: myNewIssue, inPlan: planId, completion: {
                        group.leave()
                    })
                }

            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    private func uploadMinistersIssueActions(forIssue issue: MinisterIssue, inPlan planId: String, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for action in issue.actions {
            let actionId = action.localId
            let issueId = "\(issue.remoteId)"

            group.enter()

            guard let myAction = DataServices.ministersIssueAction(withLocalId: actionId) else {
                group.leave()
                return
            }

            APIManager.add(action: myAction, toIssue: issueId, inPlan: planId) { (response, error) in
                guard let response = response, error == nil else {
                    fatalError()
                }

                // Were on a new thread now !
                if let myNewAction = DataServices.ministersIssueAction(withLocalId: actionId), let realm = try? Realm() {
                    do {
                        try realm.write {
                            myNewAction.remoteId = response["id"] as! Int
                        }
                        group.leave()
                    } catch {
                        fatalError() // just for now.
                    }
                }
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func uploadPastures(forPlan plan: RUP, completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        for pasture in plan.pastures {
            let pastureId = pasture.localId
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
                            pasture.remoteId = response["id"] as! Int
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

    private func uploadSchedules(forPlan plan: RUP, completion: @escaping () -> Void) {

        let group = DispatchGroup()

        for schedule in plan.schedules {
            let scheduleId = schedule.localId
            let planId = "\(plan.remoteId)"

            group.enter()

            guard let mySchedule = DataServices.schedule(withLocalId: scheduleId) else {
                group.leave()
                return
            }

            APIManager.add(schedule: mySchedule, toPlan: planId) { (response, error) in
                guard let response = response, error == nil else {
                    fatalError()
                }

                // Were on a new thread now !
                if let schedule = DataServices.schedule(withLocalId: scheduleId), let realm = try? Realm() {
                    do {
                        try realm.write {
                            schedule.remoteId = response["id"] as! Int
                        }
                        group.leave()
                    } catch {
                        fatalError() // just for now.
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    func updateStatuses(forPlans plans: [RUP], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for plan in plans {
            let planId = "\(plan.localId)"
            group.enter()

            guard let planObject = DataServices.plan(withLocalId: planId) else {
                group.leave()
                return completion()
            }
            APIManager.getPlanStatus(forPlan: planObject) { (response) in
                if response.result.description == "SUCCESS", let value = response.result.value {
                    let json = JSON(value)
                    guard let id = json["plan"]["statusId"].int else {
                        group.leave()
                        return completion()
                    }
                    if let refetchPlanObject = DataServices.plan(withLocalId: planId) {
                        refetchPlanObject.updateStatusId(newID: id)
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}
