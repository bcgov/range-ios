//
//  AgreementExemptionStatus.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AgreementExemptionStatus: Object {
    @objc dynamic var realmID: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: Int = -1
    @objc dynamic var desc: String = ""
    @objc dynamic var code: String = ""
}
