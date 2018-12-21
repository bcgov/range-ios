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

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var notes: String = ""
    @objc dynamic var year: Int = 2000
    var yearString: String {
        return "\(year)"
    }
    
    var scheduleObjects = List<ScheduleObject>()

    // MARK: Initializations
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

    // MARK: Deletion
    func deleteSubEntries() {
        for element in self.scheduleObjects {
            RealmRequests.deleteObject(element)
        }
    }

    // MARK: Getters
    // Note: If schedule object is invalid, it won't be added
    func getEntriesDictionary() -> [[String: Any]]{
        var r = [[String: Any]]()
        for obj in scheduleObjects where !obj.toDictionary().isEmpty {
            r.append(obj.toDictionary())
        }
        return r
    }

    func getTotalAUMs() -> Double {
        var total = 0.0
        for object in self.scheduleObjects {
            total = total + object.getCrownAUMs()
        }
        return total
    }

    // MARK: Setters
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

    // MARK: Export
    func toDictionary()  -> [String:Any] {
        let schedule: [String: Any] = [
            "year": year,
            "grazingScheduleEntries": getEntriesDictionary(),
            "narative": notes
        ]

        return schedule
    }

    func copy(in plan: Plan) -> Schedule {
        let schedule = Schedule()
        schedule.remoteId = self.remoteId
        schedule.year = self.year
        schedule.notes = self.notes
        for object in self.scheduleObjects {
            schedule.scheduleObjects.append(object.copy(in: plan))
        }

        return schedule
    }
}
