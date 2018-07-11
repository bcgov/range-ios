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

    func copy() -> MonitoringArea {
        let new = MonitoringArea()
        new.name = self.name

        return new
    }
}
