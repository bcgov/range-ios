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

    @objc dynamic var noGrazeOutSelected: Bool = false
    @objc dynamic var noGrazeInDay: Int = 1
    @objc dynamic var noGrazeInMonth: Int = 1
    @objc dynamic var noGrazeInSelected: Bool = false
    @objc dynamic var noGrazeOutDay: Int = 1
    @objc dynamic var noGrazeOutMonth: Int = 12

    func copy() -> PastureAction {
        let new = PastureAction()
        new.details = self.details
        new.action = self.action
        new.noGrazeOutSelected = self.noGrazeOutSelected
        new.noGrazeInDay = self.noGrazeInDay
        new.noGrazeInMonth = self.noGrazeInMonth
        new.noGrazeInSelected = self.noGrazeInSelected
        new.noGrazeOutDay = self.noGrazeOutDay
        new.noGrazeOutMonth = self.noGrazeOutMonth
        return new
    }

    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }
}
