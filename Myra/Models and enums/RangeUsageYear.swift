//
//  RangeUsageYears.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RangeUsageYear: Object {

    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: Int = 0
    @objc dynamic var auth_AUMs: Int = 0
    @objc dynamic var totalAnnual: Int = 0
    @objc dynamic var tempIncrease: Int = 0
    @objc dynamic var totalNonUse: Int = 0
    @objc dynamic var agreementId: String = ""
    @objc dynamic var year: Int = 0

}
