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
import SwiftyJSON

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
    var pastureGraceDays: Int {
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
    // name used for sorting
    @objc dynamic var liveStockTypeName: String = ""
    @objc dynamic var numberOfAnimals: Int = 0
    @objc dynamic var dateIn: Date?
    @objc dynamic var dateOut: Date?
    @objc dynamic var totalAUMs: Double = 0
    @objc dynamic var pldAUMs: Double = 0
    @objc dynamic var scheduleDescription: String = ""
    @objc dynamic var graceDays: Int = 0

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

    func copy(in plan: RUP) -> ScheduleObject {
        let entry = ScheduleObject()

        /*
         When copying a plan, schedule objects lose their reference to pastures
         because copied pastures have new ids/addresses.
         so we need to find the new pasture from the rup that has passed
         */
        for object in plan.pastures where object.name == self.pastureName {
            entry.pasture = object
        }
        entry.liveStockTypeId = self.liveStockTypeId
        entry.liveStockTypeName = self.liveStockTypeName
        entry.numberOfAnimals = self.numberOfAnimals
        entry.dateIn = self.dateIn
        entry.dateOut = self.dateOut
        entry.totalAUMs = self.totalAUMs
        entry.pldAUMs = self.pldAUMs
        entry.scheduleDescription = self.scheduleDescription
        entry.isNew = self.isNew

        return entry
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

    convenience init(json: JSON, plan: RUP) {
        self.init()
        
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let pastureId = json["pastureId"].int, let pasture = plan.pastureWith(remoteId: pastureId) {
            self.pasture = pasture
        }

        if let livestockCount = json["livestockCount"].int {
            self.numberOfAnimals = livestockCount
        }

        if let livestockTypeId = json["livestockTypeId"].int {
            self.liveStockTypeId = livestockTypeId
        }

        if let livestockTypeName = json["livestockType"]["name"].string {
            self.liveStockTypeName = livestockTypeName
        }

        if let gDays = json["graceDays"].int {
            self.graceDays = gDays
        }

        if let dateIn = json["dateIn"].string {
            self.dateIn = DateManager.fromUTC(string: dateIn)
        }

        if let dateOut = json["dateOut"].string {
            self.dateOut = DateManager.fromUTC(string: dateOut)
        }

    }

}

