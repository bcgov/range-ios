//
//  AmendmentHelper.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-31.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

enum AmendableStatus {
    case Stands
    case SubmittedForFinalDecision
    case SubmittedForReview
    case RecommendReady
    case Pending
    case Approved
}

class AmendmentFlowModeModel {
    
    var title: String
    var subtitle: String
    
    var optionZero: String
    var optionTwo: String
    var optionThree: String
    
    var enableInformedOption: Bool
    
    
    init(title: String, subtitle: String, optionZero: String, optionTwo: String, optionThree: String, enableInformedOption: Bool) {
        self.title = title
        self.subtitle = subtitle
        
        self.optionZero = optionZero
        self.optionTwo = optionTwo
        self.optionThree = optionThree
        
        self.enableInformedOption = enableInformedOption
    }
}

class AmendmentHelper {
    static let shared = AmendmentHelper()
    private init() {}

    // Returns a local enum of amendable statuses
    private func getAmendableStatusFor(status: RUPStatus) -> AmendableStatus? {
        switch status {
        case .Pending:
            return .Pending
        case .Stands:
            return .Stands
        case .Approved:
            return .Approved
        case .SubmittedForReview:
            return .SubmittedForReview
        case .SubmittedForFinalDecision:
            return .SubmittedForFinalDecision
        case .RecommendReady:
            return .RecommendReady
        default:
            return nil
        }
    }
    
    func canShowAmendmentOptionsFor(plan: Plan) -> Bool {
        return (getAmendableStatusFor(status: plan.getStatus()) != nil)
    }
    
    func getFlowModelFor(status: AmendableStatus) -> AmendmentFlowModeModel {
        var title: String = ""
        var subtitle: String = ""
        var optionZero: String = ""
        var optionTwo: String = ""
        var optionThree: String = ""
        var enableInformedOption: Bool = false
        
        switch status {
        case .Pending:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        case .Stands:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        case .Approved:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        case .SubmittedForReview:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        case .SubmittedForFinalDecision:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        case .RecommendReady:
            title = ""
            subtitle = ""
            optionZero = ""
            optionTwo = ""
            optionThree = ""
            enableInformedOption = false
        }
        return AmendmentFlowModeModel(title: title, subtitle: subtitle, optionZero: optionZero, optionTwo: optionTwo, optionThree: optionThree, enableInformedOption: enableInformedOption)
    }
    
    private func getFlowModeFor(status: AmendableStatus) -> AmendmentFlowMode? {
        // TODO: HERE!!!
//        switch status {
//        case .Pending:
//            return .Pending
//        case .Stands:
//            return .Stands
//        case .Approved:
//            return .Approved
//        case .SubmittedForReview:
//            return .SubmittedForReview
//        case .SubmittedForFinalDecision:
//            return .SubmittedForFinalDecision
//        case .RecommendReady:
//            return .RecommendReady
//        }
        return nil
    }
}
