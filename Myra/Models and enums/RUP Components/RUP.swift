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
import SwiftyJSON

class RUP: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1


    var statusEnum: RUPStatus {
        get {
            if let s = RUPStatus(rawValue: status) {
                return s
            } else {
                return .Unknown
            }
        }
        set {
            status = newValue.rawValue
        }
    }

    @objc dynamic var info: String = ""
    @objc dynamic var primaryAgreementHolderFirstName: String = ""
    @objc dynamic var primaryAgreementHolderLastName: String = ""

    // Local status
    @objc dynamic var status: String = RUPStatus.LocalDraft.rawValue

    @objc dynamic var agreementId: String = ""
    @objc dynamic var planStartDate: Date?
    @objc dynamic var planEndDate: Date?
    @objc dynamic var agreementStartDate: Date?
    @objc dynamic var agreementEndDate: Date?
    @objc dynamic var rangeName: String = ""
    @objc dynamic var alternativeName: String = ""
    @objc dynamic var updatedAt: Date?
    @objc dynamic var typeId: Int = 0
    @objc dynamic var ranNumber: Int = 0

    // Remote status
    @objc dynamic var statusId: Int = 0
    @objc dynamic var statusIdValue: String = ""

    @objc dynamic var isNew = false

    var rangeUsageYears = List<RangeUsageYear>()
    var liveStockIDs = List<LiveStockID>()
    var pastures = List<Pasture>()
    var schedules = List<Schedule>()
    var ministerIssues = List<MinisterIssue>()
    // we cant store nested realm objects, so we need to store the zone in list
    var zones = List<Zone>()
    var clients = List<Client>()

    func getStatus() -> RUPStatus {
        // if it's a local draft
        if self.statusEnum == .LocalDraft {
            return self.statusEnum
        }

        // if there is a remote status, use it
        if let temp = RUPManager.shared.getStatus(forId: statusId) {
            var statusName = temp.name.trimmingCharacters(in: .whitespaces)
            // Remote Draft status means its a client's draft
            if statusName == "Draft" { statusName = "ClientDraft"}
            guard let result = RUPStatus(rawValue: statusName) else {
                return .Unknown
            }
            return result
        // otherwise use local status
        } else {
            return self.statusEnum
        }

    }
    
    func setFrom(agreement: Agreement) {
        self.agreementId = agreement.agreementId
        self.agreementStartDate = agreement.agreementStartDate
        self.agreementEndDate = agreement.agreementEndDate
        self.typeId = agreement.typeId
        for c in agreement.clients {
            self.clients.append(c)
        }
        for z in agreement.zones {
            self.zones.append(z)
        }
//        self.clients = agreement.clients
//        self.zones = agreement.zones
        for y in agreement.rangeUsageYears {
            self.rangeUsageYears.append(y)
        }
//        self.rangeUsageYears = agreement.rangeUsageYears
        let splitRan = agreementId.split(separator: "N")
        self.ranNumber = Int(splitRan[1]) ?? 0
    }

    func updateStatusId(newID: Int) {
        let statusObject = RUPManager.shared.getStatus(forId: newID)
        guard let obj = statusObject else {return}
        do {
            let realm = try Realm()
            try realm.write {
                statusId = newID
                statusIdValue = obj.name
            }
        } catch _ {
            fatalError()
        }
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

    func pastureWith(remoteId: Int) -> Pasture? {
        for pasture in pastures {
            if pasture.remoteId == remoteId {
                return pasture
            }
        }
        return nil
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

    func populateFrom(json: JSON) {
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let planStart = json["planStartDate"].string {
            self.planStartDate = DateManager.fromUTC(string: planStart)
        }

        if let planEndDate = json["planEndDate"].string {
            self.planEndDate = DateManager.fromUTC(string: planEndDate)
        }

        if let rangeName = json["rangeName"].string {
            self.rangeName = rangeName
        }
        
        if let statusId = json["statusId"].int, let statusObject = RUPManager.shared.getStatus(forId: statusId) {
            // set remote status
            self.statusId = statusId
            self.statusIdValue = statusObject.name
            let statusName = statusObject.name.trimmingCharacters(in: .whitespaces)

            // set local status
            if let result = RUPStatus(rawValue: statusName) {
                self.statusEnum = result
            } else {
                self.statusEnum = .Unknown
            }
        }

        let pastures = json["pastures"]
        for pasture in pastures {
            self.pastures.append(Pasture(json: pasture.1))
        }

        let issues = json["ministerIssues"]
        for issue in issues {
            self.ministerIssues.append(MinisterIssue(json: issue.1))
        }

        let grazingSchedules = json["grazingSchedules"]
        for element in grazingSchedules {
            self.schedules.append(Schedule(json: element.1, plan: self))
        }
//        RealmRequests.saveObject(object: self)
    }
}
