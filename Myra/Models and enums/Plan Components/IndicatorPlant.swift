//
//  IndicatorPlant.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Extended
import SwiftyJSON

class IndicatorPlant: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var type: String = ""
    @objc dynamic var number: Double = 0
    @objc dynamic var criteria: String = ""

    // MARK: Initializations
    convenience init(criteria: String) {
        self.init()
        self.criteria = criteria.lowercased()
    }

    convenience init(json: JSON) {
        self.init()

        if let id = json["id"].int {
            self.remoteId = id
        }
        if let criteria = json["criteria"].string {
            self.criteria = criteria
        }

        if let value = json["value"].double {
            self.number = value
        }

        if let plantSpecies = json["plantSpecies"].dictionaryObject, let plantSpeciesName = plantSpecies["name"] as? String {
            self.type = plantSpeciesName
        }

        if let name = json["name"].string {
            if !name.isEmpty {
                self.type = name
            }
        }
    }

    // MARK: Setters
    func setDetail(text: String) {
        if text.isDouble, let doubleValue = Double(text) {
            do {
                let realm = try Realm()
                try realm.write {
                    number = doubleValue
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }
    }

    func setType(string: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.type = string
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteId = id
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Export
    func toDictionary() -> [String: Any] {
        var speciesId = 0
        var otherSpecies = ""
        if let species = Reference.shared.getIndicatorPlant(named: type) {
            speciesId = species.id
            if species.name.lowercased() == "other" {
                otherSpecies = type
            }
        }

        return [
            "plantSpeciesId": speciesId,
            "name": otherSpecies,
            "criteria": criteria.lowercased(),
            "value": number
        ]
    }

    func copy() -> IndicatorPlant {
        let new = IndicatorPlant()
        new.remoteId = self.remoteId
        new.number = self.number
        new.criteria = self.criteria
        new.type = self.type
        return new
    }
}
