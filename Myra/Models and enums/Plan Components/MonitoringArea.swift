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

class MonitoringArea: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var name: String = ""

    @objc dynamic var location: String = ""
    @objc dynamic var latitude: String = ""
    @objc dynamic var longitude: String = ""
    @objc dynamic var transectAzimuth: String = ""
    @objc dynamic var rangelandHealth: String = ""
    @objc dynamic var purpose: String = ""

    func requiredFieldsAreFilled() -> Bool {
        if self.rangelandHealth.isEmpty || self.name.isEmpty || self.location.isEmpty || self.purpose.isEmpty {
            return false
        } else {
            return true
        }
    }

    func copy() -> MonitoringArea {
        let new = MonitoringArea()
        new.location = self.location
        new.latitude = self.latitude
        new.longitude = self.longitude
        new.transectAzimuth = self.transectAzimuth
        new.rangelandHealth = self.rangelandHealth
        new.purpose = self.purpose
        new.name = self.name
        return new
    }

    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }
}
