//
//  RealmManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-19.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class RealmManager {
    static let shared = RealmManager()

    private init() {}

    // Reference
    func clearReferenceData() {
        let one = getAgreementTypes()
        let two = getAgreementStatuses()
        let three = getLiveStockType()
        for x in one {
            RealmRequests.deleteObject(x)
        }
        for x2 in two {
            RealmRequests.deleteObject(x2)
        }
        for x3 in three {
            RealmRequests.deleteObject(x3)
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

    func getLiveStockTypeObject(name: String) -> (Bool, LiveStockType?) {
        let objects = getLiveStockType()
        for object in objects {
            if object.name == name {
                return (true, object)
            }
        }
        return (false, nil)
    }
    // END OF Reference

}
