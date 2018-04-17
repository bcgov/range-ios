//
//  Client.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Client: Object {
    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var locationCode: String = ""
    @objc dynamic var startDate: Date?
    @objc dynamic var clientTypeCode: String = ""

    func set(id: String, name: String, locationCode: String, startDate: Date, clientTypeCode: String) {
        self.id = id
        self.name = name
        self.locationCode = locationCode
        self.startDate = startDate
        self.clientTypeCode = clientTypeCode
    }
}
