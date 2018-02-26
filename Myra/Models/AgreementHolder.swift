//
//  AgreementHolder.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class AgreementHolder {
    var firstName: String = ""
    var lastName: String = ""
    var type: AgreementHolderType = .Other
}

enum AgreementHolderType {
    case Primary
    case Other
}
