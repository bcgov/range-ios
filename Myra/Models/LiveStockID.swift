//
//  LiveStockID.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
class LiveStockID {
    var ownerFirstName: String = ""
    var ownerLastName: String = ""
    var type: LiveStockIDType = .Brand
    var description: String = ""
}

enum LiveStockIDType {
    case Brand
    case Tag
}
