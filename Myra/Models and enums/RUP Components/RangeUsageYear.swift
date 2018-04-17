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

class RangeUsageYear: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var id: Int = 0
    @objc dynamic var auth_AUMs: Int = 0
    @objc dynamic var totalAnnual: Int = 0
    @objc dynamic var tempIncrease: Int = 0
    @objc dynamic var totalNonUse: Int = 0
    @objc dynamic var agreementId: String = ""
    @objc dynamic var year: Int = 0

}
