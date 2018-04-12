//
//  AgreementHolder.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AgreementHolder: Object {
    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var type: String = AgreementHolderType.Other.rawValue

    var typeEnum: AgreementHolderType {
        get {
            return AgreementHolderType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
}
