//
//  SyncDate.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class SyncDate: Object {
    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var fullSync: Date?
    @objc dynamic var refDownload: Date?
}
