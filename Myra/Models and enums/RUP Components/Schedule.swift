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
    
    var scheduleObjects = List<ScheduleObject>()

    func toDictionary()  -> [String:Any] {
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
