//
//  Amendment.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class Amendment {
    var type: AmendmentChangeType?
    var InformedAgreementHolder: Bool = false
    var notes: String = ""

    func canConfirm() -> Bool {
        return type != nil && InformedAgreementHolder
    }

    func getStatus() -> RUPStatus? {
        if let type = self.type {
            switch type {
            case .Stands:
                return .Stands
            case .WronglyMadeStands:
                return .StandsWronglyMade
            case .WronglyMadeNoEffect:
                return .WronglyMadeWithoutEffect
            case .Ready:
                return .RecommendReady
            case .NotReady:
                return .RecommendNotReady
            case .NotApprovedFurtherWorkRequired:
                return .NotApprovedFurtherWorkRequired
            case .NotApproved:
                return .NotApproved
            case .Approved:
                return .Approved
            case .Completed:
                return .Completed
            case .ChangeRequested:
                return .ChangeRequested
            case .RequestAgreementHolderInput:
                return .LocalDraft
            case .RequestAgreementHolderEsignature:
                return .LocalDraft
            }
        }
        return nil
    }
}
