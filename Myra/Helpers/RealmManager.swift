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

    func getLastSyncObject() -> SyncDate? {
        if let query = RealmRequests.getObject(SyncDate.self), let last = query.last {
            return last
        } else {
            return nil
        }
    }

    func getLastSyncDate() -> Date? {
        if let query = RealmRequests.getObject(SyncDate.self), let last = query.last {
            return last.fullSync
        } else {
            return nil
        }
    }

    func getLastRefDownload() -> Date? {
        if let query = RealmRequests.getObject(SyncDate.self), let last = query.last {
            return last.refDownload
        } else {
            return nil
        }
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

    func deleteAllStoredAgreements() {
        let all = RUPManager.shared.getAgreements()
        for element in all {
            for zone in element.zones {
                RealmRequests.deleteObject(zone)
            }

            for rup in element.rups {
                // DO NOT remove local drafts: may have been not valid for upload
                if rup.getStatus() != .LocalDraft {
                    RealmRequests.deleteObject(rup)
                }
            }

            for client in element.clients {
                RealmRequests.deleteObject(client)
            }

            for years in element.rangeUsageYears {
                RealmRequests.deleteObject(years)
            }

            RealmRequests.deleteObject(element)
        }
    }

    // MARK: Refetching objects
    func plan(withLocalId localId: String) -> RUP? {
        guard let realm = try? Realm(), let plan = realm.objects(RUP.self).filter("localId = %@", localId).first else {
            return nil
        }
        return plan
    }

    func plan(withRemoteId remoteId: Int) -> RUP? {
        guard let realm = try? Realm(), let plan = realm.objects(RUP.self).filter("remoteId = %@", remoteId).first else {
            return nil
        }
        return plan
    }

    func pasture(withLocalId localId: String) -> Pasture? {
        guard let pastures = try? Realm().objects(Pasture.self).filter("localId = %@", localId), let pasture = pastures.first else {
            return nil
        }
        return pasture
    }

    func plantCommunity(withLocalId localId: String) -> PlantCommunity? {
        guard let plantCommunities = try? Realm().objects(PlantCommunity.self).filter("localId = %@", localId), let plantCommunity = plantCommunities.first else {
            return nil
        }
        return plantCommunity
    }

    func indicatorPlant(withLocalId localId: String) -> IndicatorPlant? {
        guard let indicatorPlants = try? Realm().objects(IndicatorPlant.self).filter("localId = %@", localId), let indicatorPlant = indicatorPlants.first else {
            return nil
        }
        return indicatorPlant
    }

    func monitoringArea(withLocalId localId: String) -> MonitoringArea? {
        guard let monitoringAreas = try? Realm().objects(MonitoringArea.self).filter("localId = %@", localId), let monitoringArea = monitoringAreas.first else {
            return nil
        }
        return monitoringArea
    }

    func invasivePlants(withLocalId localId: String) -> InvasivePlants? {
        guard let invasivePlants = try? Realm().objects(InvasivePlants.self).filter("localId = %@", localId), let invasivePlantsObj = invasivePlants.first else {
            return nil
        }
        return invasivePlantsObj
    }

    func pastureAction(withLocalId localId: String) -> PastureAction? {
        guard let pastureActions = try? Realm().objects(PastureAction.self).filter("localId = %@", localId), let pastureAction = pastureActions.first else {
            return nil
        }
        return pastureAction
    }


    func ministersIssue(withLocalId localId: String) -> MinisterIssue? {
        guard let issues = try? Realm().objects(MinisterIssue.self).filter("localId = %@", localId), let issue = issues.first else {
            return nil
        }
        return issue
    }

    func ministersIssueAction(withLocalId localId: String) -> MinisterIssueAction? {
        guard let actions = try? Realm().objects(MinisterIssueAction.self).filter("localId = %@", localId), let action = actions.first else {
            return nil
        }
        return action
    }

    func schedule(withLocalId localId: String) -> Schedule? {
        guard let schedules = try? Realm().objects(Schedule.self).filter("localId = %@", localId), let schedule = schedules.first else {
            return nil
        }
        return schedule
    }

    func agreement(withAgreementId id: String) -> Agreement? {
        guard let realm = try? Realm(), let agreement = realm.objects(Agreement.self).filter("agreementId = %@", id).first else {
            return nil
        }
        return agreement
    }
}
