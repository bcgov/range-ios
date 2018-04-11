//
//  District.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class District: Object {
    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: Int = -1
    @objc dynamic var code: String = ""
    @objc dynamic var desc: String = ""

    func set(id: Int, code: String, desc: String) {
        self.id = id
        self.code = code
        self.desc = desc
    }

}
