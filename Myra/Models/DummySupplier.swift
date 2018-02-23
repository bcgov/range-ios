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
        for _ in 1...count {
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
            pastures.append(Pasture())
        }
        return pastures
    }
}
