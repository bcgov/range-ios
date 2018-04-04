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
    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var allowedAUMs: Int = 0
    @objc dynamic var privateLandDeduction: Double = 0.0
    @objc dynamic var graceDays: Int = 0
    @objc dynamic var dbID: Int = -1
    var plantCommunities = List<PlantCommunity>()

    func toJSON(planID: Int) -> [String : Any] {
        return [
            "name": name,
            "allowableAum": allowedAUMs,
            "graceDays": graceDays,
            "pldPercent": (privateLandDeduction/100),
            "planId": planID
        ]
    }
}
