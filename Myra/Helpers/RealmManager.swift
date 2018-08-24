//
//  RealmManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-19.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager {
    static let shared = RealmManager()

    private init() {}

    func clearAllData() {

        do {
            let realm = try! Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch _ {
            fatalError()
        }
    }

    func getLastSyncDate() -> Date? {
        let query = RealmRequests.getObject(SyncDate.self)
        if query != nil {
            return query?.last?.fullSync
        }
        return nil
    }

    func getLastRefDownload() -> Date? {
        if let query = RealmRequests.getObject(SyncDate.self) {
            return query.last?.refDownload
        }
        return nil
    }

    func updateLastSyncDate(date: Date, DownloadedReference: Bool) {
        clearLastSyncDate()
        let syncDate = SyncDate()
        syncDate.fullSync = date
        if DownloadedReference {
            syncDate.refDownload = date
        }
        RealmRequests.saveObject(object: syncDate)
    }

    func clearLastSyncDate() {
        if let query = RealmRequests.getObject(SyncDate.self) {
            for element in query {
                RealmRequests.deleteObject(element)
            }
        }
    }

    // Reference
    func clearReferenceData() {
        var reference: [Object] = getReferenceData()
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
        return reference
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
    // END OF Reference

    // MARK: Deleting objects
    func deletePastureAction(object: PastureAction) {
        do {
            let realm = try Realm()
            if let temp = realm.objects(PastureAction.self).filter("localId = %@", object.localId).first {
                RealmRequests.deleteObject(temp)
            }
        } catch _ {
            fatalError()
        }
    }

    func deleteMonitoringArea(object: MonitoringArea) {
        do {
            let realm = try Realm()
            if let temp = realm.objects(MonitoringArea.self).filter("localId = %@", object.localId).first {
                RealmRequests.deleteObject(temp)
            }
        } catch _ {
            fatalError()
        }
    }

    func deletePlantCommunity(object: PlantCommunity) {
        do {
            let realm = try Realm()
            if let temp = realm.objects(PlantCommunity.self).filter("localId = %@", object.localId).first {
                for action in temp.pastureActions {
                    deletePastureAction(object: action)
                }

                for area in temp.monitoringAreas {
                    deleteMonitoringArea(object: area)
                }

                RealmRequests.deleteObject(temp)
            }
        } catch _ {
            fatalError()
        }
    }
}
