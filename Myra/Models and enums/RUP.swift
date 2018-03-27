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

    @objc dynamic var realmID: String = {
        return String(Int.random(min: 1, max: Int(Int32.max)))
    }()

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
    @objc dynamic var status: String = RUPStatus.Agreement.rawValue

    // set from API
    @objc dynamic var id: String = "-1"
    @objc dynamic var apistatus: String = ""
    @objc dynamic var planStartDate: Date?
    @objc dynamic var rangeName: String = ""
    @objc dynamic var alternativeName: String = ""
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var exemptionStatus: Bool = false
    @objc dynamic var agreementId: String = ""
    @objc dynamic var planEndDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var notes: String = ""
    @objc dynamic var typeId: Int = 0

    @objc dynamic var basicInformation: BasicInformation? = nil
    var rangeUsageYears = List<RangeUsageYear>()
    var agreementHolders = List<AgreementHolder>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
    var zones = List<Zone>()

    func set(id: String, status: String, zone: Zone, planStartDate: Date?, rangeName: String, agreementStartDate: Date?, updatedAt: Date?, exemptionStatus: Bool, agreementId: String, planEndDate: Date?, agreementEndDate: Date?, notes: String) {
        self.id = id
        self.planStartDate = planStartDate
        self.rangeName = rangeName
        self.agreementStartDate = agreementStartDate
        self.updatedAt = updatedAt
        self.exemptionStatus = exemptionStatus
        self.agreementId = agreementId
        self.planEndDate = planEndDate
        self.agreementEndDate = agreementEndDate
        self.notes = notes
        self.zones.append(zone)
    }
}
