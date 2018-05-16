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

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

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

    @objc dynamic var isNew = false

    var rangeUsageYears = List<RangeUsageYear>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
    // we cant store nested realm objects, so we need to store the zone in list
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
        let splitRan = agreementId.split(separator: "N")
        self.ranNumber = Int(splitRan[1]) ?? 0
    }

    func copy() -> RUP {
        let plan = RUP()

        // Copy values
        plan.remoteId = self.remoteId
        plan.info = self.info
        plan.primaryAgreementHolderFirstName = self.primaryAgreementHolderFirstName
        plan.primaryAgreementHolderLastName = self.primaryAgreementHolderLastName
        plan.status = self.status
        plan.agreementId = self.agreementId
        plan.planStartDate = self.planStartDate
        plan.planEndDate = self.planEndDate
        plan.agreementStartDate = self.agreementStartDate
        plan.agreementEndDate = self.agreementEndDate
        plan.rangeName = self.rangeName
        plan.alternativeName = self.alternativeName
        plan.updatedAt = self.updatedAt
        plan.typeId = self.typeId
        plan.ranNumber = self.ranNumber
        plan.isNew = self.isNew

        // Copy objects in lists:

        // Copy Pastures first, because Schedule objects will need to refence them.
        for object in self.pastures {
            plan.pastures.append(object.copy())
        }

        /*
         Note: Schedule objects will lose their reference to pasture during copy
         So we pass the plan so that copy() function of schedule entry can find
         reference to the new pasture object with the same name
        */
        for object in self.schedules {
            plan.schedules.append(object.copy(in: plan))
        }

        // Cients, zones and Range usage years should not be deletable/editable, so no need to call copy() on them
        plan.clients = self.clients
        plan.zones = self.zones
        plan.rangeUsageYears = self.rangeUsageYears
        
        return plan
    }

    func deleteEntries() {
        /*
         when deleting, we need to remove all pastures and schedule objects manually.
        */
        for object in self.pastures {
            RealmRequests.deleteObject(object)
        }

        for object in self.schedules {
            RealmRequests.deleteObject(object)
        }
    }

    var isValid: Bool {
        if planEndDate == nil ||
            planEndDate == nil ||
            rangeName == ""
        {
            return false
        } else {
            return true
        }
    }

    func toDictionary() -> [String:Any] {
        // if invalid, return empty dictionary
        if !isValid {
            return [String:Any]()
        }

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
