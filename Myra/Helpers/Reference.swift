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
}
