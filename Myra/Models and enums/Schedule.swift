//
//  Schedule.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Schedule: Object {

    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var year: Int = 2000
    @objc dynamic var dbID: Int = -1
    var scheduleObjects = List<ScheduleObject>()

    func toJSON()  -> [String:Any] {
        let schedule: [String: Any] = [
            "year": year,
            "grazingScheduleEntries" : getobjectsJSON()
        ]

        return schedule
    }

    // Note: If schedule object is invalid, it won't be added
    func getobjectsJSON() -> [[String: Any]]{
        var r = [[String: Any]]()
        for obj in scheduleObjects {
            if let json = obj.toJSON() {
                r.append(json)
            }
        }
        return r
    }
}
