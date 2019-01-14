//
//  MonitoringArea.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON
import Extended

class MonitoringArea: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var name: String = ""

    @objc dynamic var location: String = ""
    @objc dynamic var latitude: String = ""
    @objc dynamic var longitude: String = ""
    @objc dynamic var rangelandHealth: String = ""
    @objc dynamic var purpose: String = ""

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let name = json["name"].string {
            self.name = name
        }

        if let location = json["location"].string {
            self.location = location
        }

        if let latitude = json["latitude"].double {
            self.latitude = "\(latitude)"
        }

        if let longitude = json["longitude"].double {
            self.longitude = "\(longitude)"
        }

        if let rangelandHealth = json["rangelandHealth"].dictionaryObject, let rangelandHealthName = rangelandHealth["name"] as? String {
            self.rangelandHealth = rangelandHealthName
        }

        let purposesJSON = json["purposes"]

        purpose = ""

        if let p = json["otherPurpose"].string {
            purpose = p
        }

        for purposeJSON in purposesJSON {
            if let ptype = purposeJSON.1["purposeType"].dictionaryObject, let pName = ptype["name"] as? String, pName.lowercased() != "other" {
                if purpose.isEmpty {
                    purpose = "\(pName)"
                } else {
                    purpose = "\(purpose),\(pName)"
                }
            }
        }
    }

    // MARK: Setters
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

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        if self.rangelandHealth.isEmpty || self.name.isEmpty || self.location.isEmpty || self.purpose.isEmpty {
            return false
        } else {
            return true
        }
    }

    // MARK: Export
    func toDictionary() -> [String : Any] {
        let la = Double(latitude) ?? 0.0
        let lo = Double(longitude) ?? 0.0
        var ids: [Int] = [Int]()
        var healthId = 0

        if let healthObj = Reference.shared.getMonitoringAreaHealh(named: rangelandHealth) {
            healthId = healthObj.id
        }

        var otherPurpose: String = ""
        let purposesArray = purpose.split{$0 == ","}.map(String.init)
        for element in purposesArray {
            if let pType = Reference.shared.getMonitoringAreaPurposeType(named: element) {
                ids.append(pType.id)
                if pType.name.lowercased() == "other" {
                    otherPurpose = element
                }
            }
        }
        
        return [
            "rangelandHealthId": healthId,
            "name": name,
            "location": location,
            "latitude": la,
            "longitude": lo,
            "purposeTypeIds": ids,
            "otherPurpose": otherPurpose
        ]
    }

    func clone() -> MonitoringArea {
        let new = MonitoringArea()
        new.remoteId = self.remoteId
        new.location = self.location
        new.latitude = self.latitude
        new.longitude = self.longitude
        new.rangelandHealth = self.rangelandHealth
        new.purpose = self.purpose
        new.name = self.name
        return new
    }

}
