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

    @objc dynamic var pasture: Pasture?

    @objc dynamic var name: String = ""
    @objc dynamic var numberOfAnumals: Int = 0
    @objc dynamic var dateIn: Date?
    @objc dynamic var dateOut: Date?
    var todatlDays: Int {
        if dateIn == nil || dateOut == nil {
            return 0
        }
        return -1
    }
    var pastureName: String {
        if pasture == nil {
            return ""
        } else {
            return (pasture?.name)!
        }
    }
    @objc dynamic var type: LiveStockType?
    @objc dynamic var totalAUMs: Int = 0
    @objc dynamic var pldAUMs: Int = 0
    @objc dynamic var crownAUMs: Int = 0
    @objc dynamic var scheduleDescription: String = ""
}

