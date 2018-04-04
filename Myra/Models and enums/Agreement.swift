//
//  Agreement.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Agreement: Object {
    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

//     @objc dynamic var id: String = ""
//     @objc dynamic var agreementStartDate: Date?
//     @objc dynamic var agreementEndDate: Date?
    @objc dynamic var agreementId: String = ""
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var typeId: Int = -1
    @objc dynamic var exemptionStatusId: Int = -1
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var agreement_type_id: Int = -1
    @objc dynamic var agreement_exemption_status_id: Int = -1
    @objc dynamic var zone_id: Int = -1

    var clients = List<Client>()
    var rups = List<RUP>()
    var rangeUsageYears = List<RangeUsageYear>()
    var zones = List<Zone>()

    func set(agreementId: String, agreementStartDate: Date, agreementEndDate: Date, typeId: Int, exemptionStatusId: Int, createdAt: Date?, updatedAt: Date?, agreement_type_id: Int, agreement_exemption_status_id: Int, zone_id: Int) {
        self.agreementId = agreementId
        self.agreementStartDate = agreementStartDate
        self.agreementEndDate = agreementEndDate
        self.typeId = typeId
        self.exemptionStatusId = exemptionStatusId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.agreement_type_id = agreement_type_id
        self.agreement_exemption_status_id = agreement_exemption_status_id
        self.zone_id = zone_id
    }
}
