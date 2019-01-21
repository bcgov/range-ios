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

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1
    
    @objc dynamic var name: String = ""
    @objc dynamic var allowedAUMs: Int = -1
    @objc dynamic var privateLandDeduction: Double = 0.0
    @objc dynamic var graceDays: Int = 3
    @objc dynamic var notes: String = ""
    var plantCommunities = List<PlantCommunity>()

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()
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
            self.privateLandDeduction = (pld * 100)
        }

        if let graceDays = json["graceDays"].int {
            self.graceDays = graceDays
        }

        if let notes = json["notes"].string {
            self.notes = notes
        }

        let communities = json["plantCommunities"]
        for element in communities {
            self.plantCommunities.append(PlantCommunity(json: element.1))
        }
    }

    // MARK: Deletion
    func deleteSubEntries() {
        for element in self.plantCommunities {
            RealmRequests.deleteObject(element)
        }
    }

    // MARK: Setters
    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.remoteId = id
            }
        } catch {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setName(string: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.name = string
            }
        } catch {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        return !(self.name.isEmpty)
    }

    // MARK: Export
    func clone() -> Pasture {
        let pasture = Pasture()
        pasture.remoteId = self.remoteId
        pasture.name = self.name
        pasture.allowedAUMs = self.allowedAUMs
        pasture.privateLandDeduction = self.privateLandDeduction
        pasture.graceDays = self.graceDays
        pasture.notes = self.notes
        for object in self.plantCommunities {
            pasture.plantCommunities.append(object.copy())
        }
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
}
