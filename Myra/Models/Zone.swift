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

class Zone: Object {
    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    var district: District?
    @objc dynamic var id: Int = -1
    @objc dynamic var code: String = ""
    @objc dynamic var districtId: Int = -1
    @objc dynamic var desc: String = ""

    func set(district: District, id: Int, code: String, districtId: Int, desc: String) {
        self.district = district
        self.id = id
        self.code = code
        self.districtId = districtId
        self.desc = desc
    }
}
