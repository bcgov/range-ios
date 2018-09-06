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
