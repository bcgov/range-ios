//
//  LiveStockID.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class LiveStockID: Object {
    @objc dynamic var ownerFirstName: String = ""
    @objc dynamic var ownerLastName: String = ""
    @objc dynamic var desc: String = ""

    @objc dynamic var type: String = LiveStockIDType.Brand.rawValue

    var typeEnum: LiveStockIDType {
        get {
            return LiveStockIDType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }

}
