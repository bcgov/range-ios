//
//  BasicInformation.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-28.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class BasicInformation: Object{

    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var rangeNumber: String = ""
    @objc dynamic var planStart: Date =  Date()
    @objc dynamic var agreementStart: Date = Date()
    @objc dynamic var agreementType: String = ""
    @objc dynamic var planEnd: Date = Date()
    @objc dynamic var agreementEnd: Date = Date()
    @objc dynamic var district: String = ""
    @objc dynamic var RUPzone: String = ""
    @objc dynamic var rangeName: String = ""
    @objc dynamic var alternativeBusinessName: String = ""
}
