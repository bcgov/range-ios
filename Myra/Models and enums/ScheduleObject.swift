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

class ScheduleObject: Object {

    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
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
    @objc dynamic var type: LiveStockType?
    @objc dynamic var numberOfAnimals: Int = 0
    @objc dynamic var dateIn: Date?
    @objc dynamic var dateOut: Date?
    @objc dynamic var totalAUMs: Double = 0
    @objc dynamic var pldAUMs: Double = 0
    @objc dynamic var scheduleDescription: String = ""

}

