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

    // agreement, draft, outbox
//    @objc dynamic var state: String = "agreement"

    @objc dynamic var realmID: String = String(Int.random(min: 1, max: Int(Int32.max)))

    override class func primaryKey() -> String? {
        return "realmID"
    }

    var statusEnum: RUPStatus {
        get {
            return RUPStatus(rawValue: status)!
        }
        set {
            status = newValue.rawValue
        }
    }

    @objc dynamic var info: String = ""
    @objc dynamic var primaryAgreementHolderFirstName: String = ""
    @objc dynamic var primaryAgreementHolderLastName: String = ""
    @objc dynamic var status: String = RUPStatus.Draft.rawValue

    // if id == -1, it has not been "synced"
    // store db id on submission in this
    @objc dynamic var id: Int = -1
    @objc dynamic var agreementId: String = ""
    @objc dynamic var planStartDate: Date?
    @objc dynamic var planEndDate: Date?
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var rangeName: String = ""
    @objc dynamic var alternativeName: String = ""
    @objc dynamic var updatedAt: Date?
    @objc dynamic var typeId: Int = 0

    var rangeUsageYears = List<RangeUsageYear>()
    var agreementHolders = List<AgreementHolder>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
    var zones = List<Zone>()
    var clients = List<Client>()

    func setFrom(agreement: Agreement) {
        self.agreementId = agreement.agreementId
        self.agreementStartDate = agreement.agreementStartDate
        self.agreementEndDate = agreement.agreementEndDate
        self.typeId = agreement.typeId

        self.clients = agreement.clients
        self.zones = agreement.zones
        self.rangeUsageYears = agreement.rangeUsageYears
    }

    func toJSON() -> [String:Any] {
        let plan: [String:Any] = [
            "rangeName": rangeName,
            "agreementId": agreementId,
            "statusId": 1
        ]
        return plan
    }
}
