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

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1
    
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
    // isNew is used for highlighting cells
    @objc dynamic var isNew: Bool = false

    // MARK: Initializations
    convenience init(json: JSON, plan: Plan) {
        self.init()

        if let id = json["id"].int {
            self.remoteId = id
        }

        if let pastureId = json["pastureId"].int, let pasture = plan.getPastureWith(remoteId: pastureId) {
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

    // MARK: Getters
    func getTotalDays() -> Int {
        guard let dateIn = self.dateIn, let dateOut = self.dateOut else {return 0}
        return DateManager.daysBetween(date1: dateIn, date2: dateOut) + 1
    }

    func getPastureName() -> String {
        guard let pasture = self.pasture else {return ""}
        return pasture.name
    }

    func getPastureGraceDays() -> Int {
        guard let pasture = self.pasture else {return 0}
        return pasture.graceDays
    }

    func getCrownAUMs() -> Double {
        return totalAUMs - pldAUMs
    }

    // MARK: Setters
    func setIsNew(to: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                self.isNew = to
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func calculateAUMsAndPLD() {
        calculateTotalAUMs()
        calculatePLD()
    }

    // MARK: Calculations
    func calculateTotalAUMs() {
        var auFactor = 0.0
        // if animal type hasn't been selected, return 0
        let liveStockId = self.liveStockTypeId
        if liveStockId != -1 {
            let liveStockObject = Reference.shared.getLiveStockTypeObject(id: liveStockId)
            auFactor = liveStockObject.auFactor
        } else {
            do {
                let realm = try Realm()
                try realm.write {
                    self.totalAUMs = 0.0
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
            return
        }

        // otherwise continue...
        let numberOfAnimals = Double(self.numberOfAnimals)
        let totalDays = Double(self.getTotalDays())

        // Total AUMs = (# of Animals *Days*Animal Class Proportion)/ 30.44
        do {
            let realm = try Realm()
            try realm.write {
                self.totalAUMs = (numberOfAnimals * totalDays * auFactor) / 30.5
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func calculatePLD() {
        var pasturePLD = 0.0
        // if the schedule object doesn't have a pasture set, return 0
        if let pasture = self.pasture {
            pasturePLD = pasture.privateLandDeduction
        } else {
            do {
                let realm = try Realm()
                try realm.write {
                    self.pldAUMs = 0.0
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
            return
        }
        // otherwise continue...

        // Private Land Deduction = Total AUMs * % PLD entered for that pasture
        do {
            let realm = try Realm()
            try realm.write {
                self.pldAUMs = (self.totalAUMs * (pasturePLD / 100))
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        if self.pasture == nil || self.liveStockTypeId == -1 || self.dateIn == nil || self.dateOut == nil {
            return false
        } else {
            return true
        }
    }

    // MARK: Export
    func toDictionary() -> [String: Any] {
        guard let pasture = pasture else {
            Logger.log(message: "No pasture connected to this schedule entry\n Returning empty dictionary")
            return [String: Any]()
        }

        guard let inDate = dateIn, let outDate = dateOut else {
            Logger.log(message: "Missing in or out cate for this schedule entry\n Returning empty dictionary")
            return [String: Any]()
        }

        if liveStockTypeId == -1 {
            Logger.log(message: "Missing livestock ID for this schedule entry.\n Returning empty dictionary")
            return [String: Any]()
        }

        let schedule: [String: Any] = [
            "dateIn": DateManager.toUTC(date: inDate),
            "dateOut": DateManager.toUTC(date: outDate),
            "graceDays": graceDays,
            "livestockCount": numberOfAnimals,
            "livestockTypeId": liveStockTypeId,
            "pastureId": pasture.remoteId
        ]
        return schedule
    }

    func copy(in plan: Plan) -> ScheduleObject {
        let entry = ScheduleObject()

        /*
         When copying a plan, schedule objects lose their reference to pastures
         because copied pastures have new ids/addresses.
         so we need to find the new pasture from the rup that has passed
         */
        for pasture in plan.pastures where pasture.name == self.getPastureName() {
            entry.pasture = pasture
        }
        entry.remoteId = self.remoteId
        entry.liveStockTypeId = self.liveStockTypeId
        entry.liveStockTypeName = self.liveStockTypeName
        entry.numberOfAnimals = self.numberOfAnimals
        entry.dateIn = self.dateIn
        entry.dateOut = self.dateOut
        entry.totalAUMs = self.totalAUMs
        entry.pldAUMs = self.pldAUMs
        entry.scheduleDescription = self.scheduleDescription
        entry.isNew = self.isNew
        entry.graceDays = self.graceDays

        return entry
    }
}

