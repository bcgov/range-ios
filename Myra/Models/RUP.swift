//
//  RUP.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RUP: Object {
    
    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var id: String = ""
    @objc dynamic var info: String = ""

    @objc dynamic var primaryAgreementHolderFirstName: String = ""
    @objc dynamic var primaryAgreementHolderLastName: String = ""
    @objc dynamic var status: String = RUPStatus.Draft.rawValue

    var statusEnum: RUPStatus {
        get {
            return RUPStatus(rawValue: status)!
        }
        set {
            status = newValue.rawValue
        }
    }

    @objc dynamic var rangeName: String = ""

    @objc dynamic var basicInformation: BasicInformation? = nil
    var rangeUsageYears = List<RangeUsageYear>()
    var agreementHolders = List<AgreementHolder>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
}
