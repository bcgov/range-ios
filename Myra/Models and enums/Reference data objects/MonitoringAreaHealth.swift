//
//  MonitoringAreaHealth.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class MonitoringAreaHealth: Object {

    @objc dynamic var realmID: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var active: Bool = false
}
