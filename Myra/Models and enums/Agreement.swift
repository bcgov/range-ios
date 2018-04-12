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
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var agreementId: String = ""
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var typeId: Int = -1
    @objc dynamic var exemptionStatusId: Int = -1
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?

    var clients = List<Client>()
    var rangeUsageYears = List<RangeUsageYear>()
    var zones = List<Zone>()
    var rups = List<RUP>()

    func set(agreementId: String, agreementStartDate: Date, agreementEndDate: Date, typeId: Int, exemptionStatusId: Int, createdAt: Date?, updatedAt: Date?) {
        self.agreementId = agreementId
        self.agreementStartDate = agreementStartDate
        self.agreementEndDate = agreementEndDate
        self.typeId = typeId
        self.exemptionStatusId = exemptionStatusId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
