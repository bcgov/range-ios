//
//  ScheduleObject.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ScheduleObject: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    var totalDays: Int {
        if dateIn == nil || dateOut == nil {
            return 0
        }
        return DateManager.daysBetween(date1: dateIn!, date2: dateOut!)
    }
    var pastureName: String {
        if pasture == nil {
            return ""
        } else {
            return (pasture?.name)!
        }
    }
    var graceDays: Int {
        if pasture == nil {
            return 0
        } else {
            return (pasture?.graceDays)!
        }
    }
    var crownAUMs: Double {
        return totalAUMs - pldAUMs
    }
    
    @objc dynamic var pasture: Pasture?
    @objc dynamic var liveStockTypeId: Int = -1
    // name user for sorting
    @objc dynamic var liveStockTypeName: String = ""
    @objc dynamic var numberOfAnimals: Int = 0
    @objc dynamic var dateIn: Date?
    @objc dynamic var dateOut: Date?
    @objc dynamic var totalAUMs: Double = 0
    @objc dynamic var pldAUMs: Double = 0
    @objc dynamic var scheduleDescription: String = ""

    // Used for highlighting cell
    @objc dynamic var isNew: Bool = false

    func setIsNew(to: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                self.isNew = to
            }
        } catch _ {
            fatalError()
        }
    }

    func toDictionary() -> [String : Any]? {
        if let pastureID = pasture?.remoteId, liveStockTypeId != -1, let inDate = dateIn, let outDate = dateOut {
            let schedule: [String: Any] = [
                "startDate": DateManager.toUTC(date: inDate),
                "endDate": DateManager.toUTC(date: outDate),
                "dateIn": DateManager.toUTC(date: inDate),
                "dateOut": DateManager.toUTC(date: outDate),
                "livestockCount": numberOfAnimals,
                "livestockTypeId": liveStockTypeId,
                "pastureId": pastureID
            ]
            return schedule
        } else {
            return nil
        }
    }

}

