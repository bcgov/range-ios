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
import SwiftyJSON

class Agreement: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1
    
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
    var plans = List<Plan>()

    func primaryAgreementHolder() -> String {
        for client in self.clients {
            if client.clientTypeCode == "A" {
                return client.name
            }
        }
        return ""
    }

    convenience init(json: JSON) {
        self.init()
        if let i = json["id"].string {
            self.agreementId = i
        }

        if let dateStart = json["agreementStartDate"].string {
            self.agreementStartDate = DateManager.fromUTC(string: dateStart)
        }

        if let dateEnd = json["agreementEndDate"].string {
            self.agreementEndDate = DateManager.fromUTC(string: dateEnd)
        }

        if let type = json["agreementTypeId"].int {
            self.typeId = type
        }

        if let dateCreate = json["createdAt"].string {
            self.createdAt = DateManager.fromUTC(string: dateCreate)
        }

        if let dateUpdate = json["updatedAt"].string {
            self.updatedAt = DateManager.fromUTC(string: dateUpdate)
        }

        if let exemptionStatusNumber = json["agreementExemptionStatusId"].int {
            self.exemptionStatusId = exemptionStatusNumber
        }

        self.zones.append(Zone(json: json["zone"]))

        // Usage year objects
        // cache in array to sort before storing
        var usages: [RangeUsageYear] = [RangeUsageYear]()
        let usageJSON = json["usage"]
        for (_,usage) in usageJSON {
            usages.append(RangeUsageYear(json: usage, agreementId: agreementId))
        }

        let sortedUsages = usages.sorted(by: { $0.year < $1.year })
        for usage in sortedUsages {
            self.rangeUsageYears.append(usage)
        }

        // Clients
        let clientsJSON = json["clients"]
        for (_,clientJSON) in clientsJSON {
            self.clients.append(Client(json: clientJSON))
        }
        
        // Plan
        let plansJSON = json["plans"]

        for planJSON in plansJSON {

            if let planRemoteId = planJSON.1["id"].int {
                // if a plan with the same remore id exists, delete it and store the new one
                if let p = RUPManager.shared.getPlanWith(remoteId: planRemoteId) {
                    RealmRequests.deleteObject(p)
                }
                let plan = Plan()
                plan.importAgreementData(from: self)
                plan.populateFrom(json: planJSON.1)
                RealmRequests.saveObject(object: plan)
                self.plans.append(plan)
            }
        }
        RealmRequests.saveObject(object: self)
    }

    func getLatestPlan() -> Plan? {
        if plans.count == 1 {
            return plans.first!
        }
        var latest: Plan?
        var tempid = -2
        for plan in plans {
            if plan.getStatus() == .LocalDraft {
                return plan
            }
            if plan.remoteId > tempid {
                tempid = plan.remoteId
                latest = plan
            }
        }
        return latest
    }

    func add(plan: Plan) {
        do {
            let realm = try Realm()
            try realm.write {
                self.plans.append(plan)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func toDictionary() -> [String: Any] {
        return [String: Any]()
    }
}
