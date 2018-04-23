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

class RUP: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
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

    @objc dynamic var agreementId: String = ""
    @objc dynamic var planStartDate: Date?
    @objc dynamic var planEndDate: Date?
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var rangeName: String = ""
    @objc dynamic var alternativeName: String = ""
    @objc dynamic var updatedAt: Date?
    @objc dynamic var typeId: Int = 0
    @objc dynamic var ranNumber = 0

    var rangeUsageYears = List<RangeUsageYear>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
    var zones = List<Zone>()
    var clients = List<Client>()

//    convenience init(data: [String: Any]?) {
//        self.init()
//
//    }

    func setFrom(agreement: Agreement) {
        self.agreementId = agreement.agreementId
        self.agreementStartDate = agreement.agreementStartDate
        self.agreementEndDate = agreement.agreementEndDate
        self.typeId = agreement.typeId
        self.clients = agreement.clients
        self.zones = agreement.zones
        self.rangeUsageYears = agreement.rangeUsageYears
        let primary = RUPManager.shared.getPrimaryAgreementHolderFor(agreement: agreement)
//        let primaryArray = primary.split(separator: ",")
//        self.primaryAgreementHolderLastName = String(primaryArray[0])
//        self.primaryAgreementHolderFirstName = String(primaryArray[1])
        let splitRan = agreementId.split(separator: "N")
        self.ranNumber = Int(splitRan[1]) ?? 0
    }

    func toDictionary() -> [String:Any] {
        if planEndDate == nil || planEndDate == nil{ return [String:Any]()}
        return [
            "rangeName": rangeName,
            "agreementId": agreementId,
            "planStartDate": DateManager.toUTC(date: planStartDate!),
            "planEndDate": DateManager.toUTC(date: planEndDate!),
            "alternativeBusinessName": alternativeName,
            "statusId": 1
        ]
    }
}
