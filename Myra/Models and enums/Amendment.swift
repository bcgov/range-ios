//
//  Amendment.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation


enum AmendmentType {
    case Stands
    case WronglyMadeStands
    case WronglyMadeNoEffect
}

class Amendment {
    var type: AmendmentType?
    var InformedAgreementHolder: Bool = false
    var notes: String = ""

    func canConfirm() -> Bool {
        return type != nil && InformedAgreementHolder
    }

    func getStatus() -> RUPStatus? {
        if let type = self.type {
            if type == .WronglyMadeNoEffect {
                return .WronglyMadeWithoutEffect
            } else if type == .WronglyMadeStands {
                return .StandsWronglyMade
            } else if type == .Stands {
                return .Stands
            }
        }
        return nil
    }
}
