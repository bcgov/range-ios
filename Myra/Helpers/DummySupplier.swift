//
//  DummySupplier.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation


class DummySupplier {
    static let shared = DummySupplier()

    private init() {}

    func getRangeUseYears(count: Int) -> [RangeUsageYear] {
        var rangeUsageYears: [RangeUsageYear] = [RangeUsageYear]()
        for _ in 0...count {
            rangeUsageYears.append(getRangeUseYear())
        }

        return rangeUsageYears
    }

    func getRangeUseYear() -> RangeUsageYear {
        return RangeUsageYear()
    }

    func getPastures(count: Int) -> [Pasture] {
        var pastures: [Pasture] = [Pasture]()
        for _ in 0...count {
            let pasture = Pasture()
            pasture.name = "name"
            pasture.plantCommunities.append(PlantCommunity())
            pastures.append(pasture)
        }
        return pastures
    }

    func getAgreementHolders(count: Int) -> [AgreementHolder]{
        var agreementHolders: [AgreementHolder] = [AgreementHolder]()
        for _ in 0...count {
            let agreementHolder = AgreementHolder()
            agreementHolder.firstName = "John"
            agreementHolder.lastName = "Doe"
            agreementHolder.typeEnum = .Primary
            agreementHolders.append(agreementHolder)
        }
        return agreementHolders
    }

    func getAgreementHolder() -> AgreementHolder {
        let agreementHolder = AgreementHolder()
        agreementHolder.firstName = "John"
        agreementHolder.lastName = "Doe"
        agreementHolder.typeEnum = .Primary
        return agreementHolder
    }

    func getLiveStockIDs(count: Int) -> [LiveStockID] {
        var liveStockIDs: [LiveStockID] = [LiveStockID]()
        for _ in 0...count {
            let liveStockID = LiveStockID()
            liveStockID.ownerFirstName = "Jane"
            liveStockID.ownerLastName = "Doe"
            liveStockID.desc = "Describing this field in this field"
            liveStockID.typeEnum = .Brand
            liveStockIDs.append(liveStockID)
        }
        return liveStockIDs
    }

    func getLiveStockID() -> LiveStockID {
        let liveStockID = LiveStockID()
        liveStockID.ownerFirstName = "Jane"
        liveStockID.ownerLastName = "Doe"
        liveStockID.desc = "Describing this field in this field"
        liveStockID.typeEnum = .Brand
        return liveStockID
    }

    func createLiveStockTypes() {
        let lsts = RealmRequests.getObject(LiveStockType.self)
        if lsts != nil && !(lsts?.isEmpty)! && (lsts?.count)! > 0 {
            return
        }
        for i in 0...10 {
            let lst = LiveStockType()
            lst.type = "type\(i)"
            RealmRequests.saveObject(object: lst)
        }
    }
}
