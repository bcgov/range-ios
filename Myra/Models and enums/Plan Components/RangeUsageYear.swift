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
import SwiftyJSON

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

    convenience init(json: JSON, agreementId: String) {
        self.init()
        self.agreementId = agreementId
        if let authAUM = json["authorizedAum"].int {
            self.auth_AUMs = authAUM
        }

        if let uid = json["id"].int {
            self.id = uid
        }

        if let tAU = json["totalAnnualUse"].int{
            self.totalAnnual = tAU
        }

        if let ti = json["temporaryIncrease"].int {
            self.tempIncrease = ti
        }

        if let tnu = json["totalNonUse"].int {
            self.totalNonUse = tnu
        }

        if let yy = json["year"].int {
            self.year = Int(yy)
        }
    }

    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }

}
