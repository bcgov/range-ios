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
import SwiftyJSON

class Pasture: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }
    
    convenience init(data: [String: Any]) {
        self.init()

        name = data["name"] as! String
        allowedAUMs = data["allowableAum"] as! Int
        privateLandDeduction = data["privateLandDeduction"] as! Double
        graceDays = data["graceDays"] as! Int
        notes = data["notes"] as! String
        remoteId = data["dbID"] as! Int
    }
    
    @objc dynamic var name: String = ""
    @objc dynamic var allowedAUMs: Int = -1
    @objc dynamic var privateLandDeduction: Double = 0.0
    @objc dynamic var graceDays: Int = 3
    @objc dynamic var notes: String = ""

    var plantCommunities = List<PlantCommunity>()

    func copy() -> Pasture {
        let pasture = Pasture()
        pasture.name = self.name
        pasture.allowedAUMs = self.allowedAUMs
        pasture.privateLandDeduction = self.privateLandDeduction
        pasture.graceDays = self.graceDays
        pasture.notes = self.notes
        return pasture
    }

    func toDictionary() -> [String:Any] {
        var allowedAUM: Int? = allowedAUMs
        if allowedAUM == -1 {
            allowedAUM = nil
        }
        return [
            "name": name,
            "allowableAum": allowedAUM,
            "graceDays": graceDays,
            "pldPercent": (privateLandDeduction/100),
            "notes": notes
        ]
    }

    convenience init(json: JSON) {
        self.init()
//    func setFromJSON(json: JSON){
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let name = json["name"].string {
            self.name = name
        }

        if let aum = json["allowableAum"].int {
            self.allowedAUMs = aum
        }

        if let pld = json["pldPercent"].double {
            self.privateLandDeduction = pld
        }

        if let graceDays = json["graceDays"].int {
            self.graceDays = graceDays
        }

        if let notes = json["notes"].string {
            self.notes = notes
        }
    }
}
