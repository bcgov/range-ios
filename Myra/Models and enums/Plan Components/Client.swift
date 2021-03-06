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
import SwiftyJSON

class Client: Object {
    @objc dynamic var localId: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var locationCode: String = ""
    @objc dynamic var startDate: Date?
    @objc dynamic var clientTypeCode: String = ""

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()

        if let cid = json["id"].string {
            self.id = cid
        }

        if let cname = json["name"].string {
            self.name = cname
        }

        if let clocationCode = json["locationCode"].string {
            self.locationCode = clocationCode
        }

        if let cstart = json["startDate"].string {
            self.startDate = DateManager.fromUTC(string: cstart)
        }

        if let cclientTypeCode = json["clientTypeCode"].string {
            self.clientTypeCode = cclientTypeCode
        }
    }

    // MARK: Setters
    func set(id: String, name: String, locationCode: String, startDate: Date, clientTypeCode: String) {
        self.id = id
        self.name = name
        self.locationCode = locationCode
        self.startDate = startDate
        self.clientTypeCode = clientTypeCode
    }
}
