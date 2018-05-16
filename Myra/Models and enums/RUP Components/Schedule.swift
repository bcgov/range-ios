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

class Schedule: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var year: Int = 2000
    @objc dynamic var notes: String = ""
    
    var scheduleObjects = List<ScheduleObject>()

    func copy(in plan: RUP) -> Schedule {
        let schedule = Schedule()
        schedule.name = self.name
        schedule.year = self.year
        schedule.notes = self.notes
        for object in self.scheduleObjects {
            schedule.scheduleObjects.append(object.copy(in: plan))
        }

        return schedule
    }

    func toDictionary()  -> [String:Any] {
        let schedule: [String: Any] = [
            "year": year,
            "grazingScheduleEntries" : getEntriesDictionary(),
            "narative" : notes
        ]

        return schedule
    }

    // Note: If schedule object is invalid, it won't be added
    func getEntriesDictionary() -> [[String: Any]]{
        var r = [[String: Any]]()
        for obj in scheduleObjects {
            if let json = obj.toDictionary() {
                r.append(json)
            }
        }
        return r
    }
}
