//
//  StatusColor.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class StatusHelper {
    static func getColor(for status: RUPStatus) -> UIColor {
        switch status {
        case .Completed:
            return UIColor.green
        case .Pending:
            return UIColor.yellow
        case .LocalDraft:
            return UIColor.red
        case .Outbox:
            return UIColor.gray
        case .Created:
            return UIColor.yellow
        case .ChangeRequested:
            return UIColor.gray
        case .ClientDraft:
            return UIColor.red
        case .Unknown:
            return UIColor.gray
        case .StaffDraft:
            return UIColor.red
        case .WronglyMadeWithoutEffect:
            return UIColor.gray
        case .StandsWronglyMade:
            return UIColor.gray
        case .Stands:
            return UIColor.gray
        case .NotApprovedFurtherWorkRequired:
            return UIColor.gray
        case .NotApproved:
            return UIColor.gray
        case .Approved:
            return UIColor.gray
        case .SubmittedForReview:
            return UIColor.gray
        case .SubmittedForFinalDecision:
            return UIColor.gray
        case .RecommendReady:
            return UIColor.gray
        case .RecommendNotReady:
            return UIColor.gray
        case .ReadyForFinalDescision:
            return UIColor.gray
        case .RecommendForSubmission:
            return UIColor.gray
        }
    }
}
