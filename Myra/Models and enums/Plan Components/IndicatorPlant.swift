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

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var type: String = ""
    @objc dynamic var number: Double = 0
    @objc dynamic var criteria: String = ""

    convenience init(criteria: String) {
        self.init()
        self.criteria = criteria.lowercased()
    }

    /* Initially each indicator plant's second field, or detail could have been String or Double.
     so we used getDetail and setDetail to get and set the second field's value.
     */
    func getDetail() -> String {

//        if type.lowercased() == "custom" {
//            return criteria
//        } else {
//            if number == 0 {
//                return ""
//            } else {
//                return "\(number)"
//            }
//        }
        return "\(number)"
    }

    func setDetail(text: String) {
        if text.isDouble {
            do {
                let realm = try Realm()
                try realm.write {
                    number = Double(text)!
                }
            } catch _ {
                fatalError()
            }
        }
//        if type.lowercased() == "custom" {
//            do {
//                let realm = try Realm()
//                try realm.write {
//                    criteria = text
//                    number = 0
//                }
//            } catch _ {
//                fatalError()
//            }
//        } else if text.isDouble {
//            do {
//                let realm = try Realm()
//                try realm.write {
//                    criteria = ""
//                    number = Double(text)!
//                }
//            } catch _ {
//                fatalError()
//            }
//        } else if text == "" {
//            do {
//                let realm = try Realm()
//                try realm.write {
//                    criteria = ""
//                    number = 0
//                }
//            } catch _ {
//                fatalError()
//            }
//        }
    }

    func setType(string: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.type = string
            }
        } catch _ {
            fatalError()
        }
    }

    func copy() -> IndicatorPlant {
        let new = IndicatorPlant()
        new.remoteId = remoteId
        new.number = self.number
        new.criteria = self.criteria
        new.type = self.type
        return new
    }

    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteId = id
            }
        } catch _ {
            fatalError()
        }
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

    func toDictionary() -> [String : Any] {
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
            "value": number,
        ]
    }
}
