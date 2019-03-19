//
//  DummyData.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-30.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

class DummyData {
    
    static func createDummyPlan() -> Plan {
        let agreement = Agreement()
        agreement.agreementId = "RAN000000"
        let plan = Plan()
        plan.ranNumber = 070000
        plan.rangeName = "Tour Range"
        plan.remoteId = -99
        plan.agreementId = agreement.agreementId
        plan.updateStatus(with: .Created)
        let client = Client()
        client.name = "Roop Jawl"
        client.clientTypeCode = "A"
        plan.shouldUpdateRemoteStatus = false
        plan.clients.append(client)
        agreement.plans.append(plan)
        RealmRequests.saveObject(object: plan)
        RealmRequests.saveObject(object: agreement)
        return plan
    }
    
    static func removeDummyPlanAndAgreement() {
        for element in RUPManager.shared.getPlansWith(remoteId: -99) {
            RealmRequests.deleteObject(element)
        }
        
        for element in RUPManager.shared.getAgreements(with: "RAN000000") {
            RealmRequests.deleteObject(element)
        }
    }
}
