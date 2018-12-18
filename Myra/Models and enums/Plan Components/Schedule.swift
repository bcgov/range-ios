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
import SwiftyJSON

class Schedule: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var year: Int = 2000
    var name: String {
        return "\(year)"
    }
    @objc dynamic var notes: String = ""
    
    var scheduleObjects = List<ScheduleObject>()

    func copy(in plan: Plan) -> Schedule {
        let schedule = Schedule()
        schedule.year = self.year
        schedule.notes = self.notes
        for object in self.scheduleObjects {
            schedule.scheduleObjects.append(object.copy(in: plan))
        }

        return schedule
    }

    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.remoteId = id
            }
        } catch {
            fatalError()
        }
    }

    func toDictionary()  -> [String:Any] {
        let schedule: [String: Any] = [
            "year": year,
            "grazingScheduleEntries": getEntriesDictionary(),
            "narative": notes
        ]

        return schedule
    }

    // Note: If schedule object is invalid, it won't be added
    func getEntriesDictionary() -> [[String: Any]]{
        var r = [[String: Any]]()
        for obj in scheduleObjects where !obj.toDictionary().isEmpty{
            r.append(obj.toDictionary())
        }
        return r
    }

    convenience init(json: JSON, plan: Plan) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let narative = json["narative"].string {
            self.notes = narative
        }

        if let year = json["year"].int {
            self.year = year
        }

        let entries = json["grazingScheduleEntries"]
        for entry in entries {
            self.scheduleObjects.append(ScheduleObject(json: entry.1, plan: plan))
        }
    }

    func getTotalAUMs() -> Double {
        var total = 0.0
        for object in self.scheduleObjects {
            total = total + object.crownAUMs
        }
        return total
    }

    func deleteSubEntries() {
        for element in self.scheduleObjects {
            RealmRequests.deleteObject(element)
        }
    }
}
