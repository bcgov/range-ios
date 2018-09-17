//
//  ReferenceManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Reference {
    static let shared = Reference()
    private init() {}
    
    func clearReferenceData() {
        let reference: [Object] = getReferenceData()
        for element in reference {
            RealmRequests.deleteObject(element)
        }
    }

    func getReferenceData() -> [Object] {
        var reference: [Object] = [Object]()
        reference.append(contentsOf: getLiveStockType())
        reference.append(contentsOf: getAgreementTypes())
        reference.append(contentsOf: getAgreementStatuses())
        reference.append(contentsOf: getClientTypes())
        reference.append(contentsOf: getPlanStatuses())
        reference.append(contentsOf: getAgreementExeptionStatuses())
        reference.append(contentsOf: getIssueType())
        reference.append(contentsOf: getIssueActionType())
        reference.append(contentsOf: getAmendmentType())
        return reference
    }

    func updateReferenceData(objects: [Object]) {
        clearReferenceData()
        storeNewReferenceData(objects: objects)
    }

    func storeNewReferenceData(objects: [Object]) {
        for object in objects {
            RealmRequests.saveObject(object: object)
        }
    }

    func getClientTypes() -> [ClientType] {
        if let query = RealmRequests.getObject(ClientType.self) {
            return query
        } else {
            return [ClientType]()
        }
    }

    func getPlanStatuses() -> [PlanStatus] {
        if let query = RealmRequests.getObject(PlanStatus.self) {
            return query
        } else {
            return [PlanStatus]()
        }
    }

    func getAgreementExeptionStatuses() -> [AgreementExemptionStatus] {
        if let query = RealmRequests.getObject(AgreementExemptionStatus.self) {
            return query
        } else {
            return [AgreementExemptionStatus]()
        }
    }

    func getAgreementTypes() -> [AgreementType] {
        let query = RealmRequests.getObject(AgreementType.self)
        if query != nil {
            return query!
        } else {
            return [AgreementType]()
        }
    }

    func getAgreementStatuses() -> [AgreementStatus] {
        let query = RealmRequests.getObject(AgreementStatus.self)
        if query != nil {
            return query!
        } else {
            return [AgreementStatus]()
        }
    }

    func getLiveStockType() -> [LiveStockType] {
        let query = RealmRequests.getObject(LiveStockType.self)
        if query != nil {
            return query!
        } else {
            return [LiveStockType]()
        }
    }

    func getIssueType() -> [MinisterIssueType] {
        let query = RealmRequests.getObject(MinisterIssueType.self)
        if query != nil {
            return query!
        } else {
            return [MinisterIssueType]()
        }

    }

    func getIssueActionType() -> [MinisterIssueActionType] {
        let query = RealmRequests.getObject(MinisterIssueActionType.self)
        if query != nil {
            return query!
        } else {
            return [MinisterIssueActionType]()
        }
    }

    func getAmendmentType() -> [AmendmentType] {
        let query = RealmRequests.getObject(AmendmentType.self)
        if query != nil {
            return query!
        } else {
            return [AmendmentType]()
        }
    }

    func getAgreementTypeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = getAgreementTypes()
        for object in objects {
            returnArray.append(SelectionPopUpObject(display: object.desc, value:  object.desc))
        }
        return returnArray
    }

    func getLiveStockTypeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = getLiveStockType()
        for object in objects {
            returnArray.append(SelectionPopUpObject(display: object.name, value:  object.name))
        }
        return returnArray
    }

    func getLiveStockTypeObject(name: String) -> (LiveStockType) {
        let objects = getLiveStockType()
        for object in objects {
            if object.name.lowercased() == name.lowercased() {
                return object
            }
        }
        return LiveStockType()
    }

    func getLiveStockTypeObject(id: Int) -> (LiveStockType) {
        let objects = getLiveStockType()
        for object in objects {
            if object.id == id {
                return object
            }
        }
        return LiveStockType()
    }

    func getStaffDraftPlanStatus() -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == "sd"  {
                    return object
                }
            }
        }
        return PlanStatus()
    }

    func getCreatedPlanStatus() -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == "c"  {
                    return object
                }
            }
        }
        return PlanStatus()
    }

    func getAmendmentStatus(status: RUPStatus)  -> PlanStatus {
        var code = ""
        if status == .WronglyMadeWithoutEffect {
            code = "wm"
        } else if status == .StandsWronglyMade {
            code = "sw"
        } else if status == .Stands {
            code = "s"
        } else if status == .RecommendNotReady {
            code = "rnr"
        } else if status == .RecommendReady {
            code = "rr"
        } else if status == .NotApprovedFurtherWorkRequired {
            code = "nf"
        } else if status == .NotApproved {
            code = "na"
        } else if status == .Approved {
            code = "a"
        } else if status == .SubmittedForFinalDecision {
            code = "sfd"
        }

        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == code.lowercased()  {
                    return object
                }
            }
        }
        return PlanStatus()
    }

    func getStatus(forId id: Int) -> PlanStatus? {
        do {
            let realm = try Realm()
            let statuses = realm.objects(PlanStatus.self).filter("id = %@", id)
            return statuses.first
        } catch _ {}
        return nil
    }

    func getAmendmentType(forId id: Int) -> AmendmentType? {
        do {
            let realm = try Realm()
            let statuses = realm.objects(AmendmentType.self).filter("id = %@", id)
            return statuses.first
        } catch _ {}
        return nil
    }


    func getAgreementExemptionStatusFor(id: Int) -> AgreementExemptionStatus {
        let query = RealmRequests.getObject(AgreementExemptionStatus.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return AgreementExemptionStatus()
    }

    func getPlanStatusFor(id: Int) -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return PlanStatus()
    }

    func getStatusTooltipDeescription(for status: RUPStatus) -> String {
        return "describing \(status) status etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc"
    }

    func removeAllObjectsIn(query: [Object]?) {
        if query == nil {return}
        for object in query! {
            RealmRequests.deleteObject(object)
        }
    }

    func getClientTypeFor(clientTypeCode: String) -> ClientType {
        let query = RealmRequests.getObject(ClientType.self)
        if let all = query {
            for object in all {
                // while you're at it, clean up invalid data..
                if object.id == -1 {
                    RealmRequests.deleteObject(object)
                }
                if object.code == clientTypeCode {
                    return object
                }
            }
        }
        return ClientType()
    }

    func getIssueType(named: String) -> MinisterIssueType? {
        do {
            let realm = try Realm()
            if let obj = realm.objects(MinisterIssueType.self).filter("name = %@", named).first {
                return obj
            }
        } catch _ {
            fatalError()
        }
        return nil
    }

    func getIssueActionType(named: String) -> MinisterIssueActionType? {
        do {
            let realm = try Realm()
            if let obj = realm.objects(MinisterIssueActionType.self).filter("name = %@", named).first {
                return obj
            }
        } catch _ {
            fatalError()
        }
        return nil
    }

}
