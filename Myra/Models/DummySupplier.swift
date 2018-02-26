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
        for _ in 1...count {
            let pasture = Pasture()
            pasture.plantCommunities.append(PlantCommunity())
            pastures.append(pasture)
        }
        return pastures
    }

    func getAgreementHolders(count: Int) -> [AgreementHolder]{
        var agreementHolders: [AgreementHolder] = [AgreementHolder]()
        for _ in 1...count {
            let agreementHolder = AgreementHolder()
            agreementHolder.firstName = "John"
            agreementHolder.lastName = "Doe"
            agreementHolder.type = .Primary
            agreementHolders.append(agreementHolder)
        }
        return agreementHolders
    }

    func getAgreementHolder() -> AgreementHolder {
        let agreementHolder = AgreementHolder()
        agreementHolder.firstName = "John"
        agreementHolder.lastName = "Doe"
        agreementHolder.type = .Primary
        return agreementHolder
    }
}
