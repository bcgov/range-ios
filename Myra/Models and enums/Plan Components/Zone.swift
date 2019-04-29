//
//  Zone.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class Zone: Object {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var id: Int = -1
    @objc dynamic var code: String = ""
    @objc dynamic var districtId: Int = -1
    @objc dynamic var desc: String = ""
    @objc dynamic var contactName: String = "Not Provided"
    @objc dynamic var contactPhoneNumber: String = "Not Provided"
    @objc dynamic var contactEmail: String = "Not Provided"
    var districts = List<District>()

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.id = id
        }
        if let code = json["code"].string {
            self.code = code
        }
        if let districtId = json["districtId"].int {
            self.districtId = districtId
        }
        if let desc = json["description"].string {
            self.desc = desc
        }

        // Zone user
        let zoneUser = json["user"]
        var firstName = ""
        var lastName = ""

        if let zoneUserName = zoneUser["givenName"].string {
            firstName = zoneUserName
        }

        if let zoneUserFamilyName = zoneUser["familyName"].string {
            lastName = zoneUserFamilyName
        }

        self.contactName = "\(firstName) \(lastName)"

        if let contactPhoneNumber = zoneUser["phoneNumber"].string {
            self.contactPhoneNumber = contactPhoneNumber
        }

        if let contactEmail = zoneUser["email"].string {
            self.contactEmail = contactEmail
        }
        
        self.districts.append(District(json: json["district"]))
    }
}
