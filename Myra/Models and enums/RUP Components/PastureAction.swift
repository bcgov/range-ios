//
//  PastureAction.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PastureAction: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var details: String = ""
    @objc dynamic var action: String = ""
    @objc dynamic var noGrazeDateIn: Date?
    @objc dynamic var noGrazeDateOut: Date?

    func copy() -> PastureAction {
        let new = PastureAction()
        new.details = self.details
        new.action = self.action
        new.noGrazeDateIn = self.noGrazeDateIn
        new.noGrazeDateOut = self.noGrazeDateOut
        return new
    }
}
