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
import SwiftyJSON

class District: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var id: Int = -1
    @objc dynamic var code: String = ""
    @objc dynamic var desc: String = ""

    func set(id: Int, code: String, desc: String) {
        self.id = id
        self.code = code
        self.desc = desc
    }

    convenience init(json: JSON) {
        self.init()
        if let distId = json["id"].int {
            self.id = distId
        }
        if let distDesc = json["description"].string {
            self.desc = distDesc
        }
        if let distCode = json["code"].string {
            self.code = distCode
        }
    }

}
