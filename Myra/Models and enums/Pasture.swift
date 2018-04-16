//
//  Pasture.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Pasture: Object {
    
    convenience init(data: [String: Any]) {
        self.init()

        name = data["name"] as! String
        allowedAUMs = data["allowableAum"] as! Int
        privateLandDeduction = data["privateLandDeduction"] as! Double
        graceDays = data["graceDays"] as! Int
        notes = data["notes"] as! String
        dbID = data["dbID"] as! Int
    }
    
    override class func primaryKey() -> String? {
        return "realmID"
    }
    
    @objc dynamic var realmID: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var allowedAUMs: Int = 0
    @objc dynamic var privateLandDeduction: Double = 0.0
    @objc dynamic var graceDays: Int = 3
    @objc dynamic var notes: String = ""
    @objc dynamic var dbID: Int = -1
    var plantCommunities = List<PlantCommunity>()

    func toDictionary() -> [String:Any] {
        return [
            "name": name,
            "allowableAum": allowedAUMs,
            "graceDays": graceDays,
            "pldPercent": (privateLandDeduction/100),
            "notes": notes
        ]
    }
}
