//
//  PlantCommunity.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PlantCommunity: Object {

    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var name: String = ""
}
