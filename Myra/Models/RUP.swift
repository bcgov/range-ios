//
//  RUP.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class RUP {
    var id: String = ""
    var info: String = ""

    var primaryAgreementHolderFirstName: String = ""
    var primaryAgreementHolderLastName: String = ""

    var status: RUPStatus?

    var rangeName: String = ""

    var basicInformation: BasicInformation = BasicInformation()
    var rangeUsageYears: [RangeUsageYear] = [RangeUsageYear]()
    var agreementHolders: [AgreementHolder] = [AgreementHolder]()
    var liveStockIDs: [LiveStockID] = [LiveStockID]()
    var pastures: [Pasture] = [Pasture]()

    init(id: String) {
        self.id = id
    }

    init(id: String, info: String) {
        self.id = id
        self.info = info
    }
}
