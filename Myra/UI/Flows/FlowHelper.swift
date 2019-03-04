//
//  PlanStatusFlows.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class FlowHelper {
    /*
     If adding a new flow for another status:
     1) add status that initiates it in StatusWithFlow enum
     2) Edit switch statement in FlowOption enum
     3) Add the options for the flow in FlowOption enum
     4) you will see warnings from other switch staments that use the enums,
     decide how to handle those cases.
     
     When updating translate functions and adding enum cases,
     use same sataus names as RUPStatus cases
     */
    
    static let shared = FlowHelper()
    
    public init() {}
    
    //    public func getflowFor(status: RUPStatus, plan: Plan) -> FlowModel? {
    //        // If StatusWithFlow doesn't include this status, return nil
    //        guard let translatedStatus = translate(planStatus: status) else {return nil}
    //        let stat = plan.getStatus()
    ////        let isInitial =
    //        let actionName = actionNameFor(status: translatedStatus)
    //        let flowView = flowViewFor(status: translatedStatus)
    //        return FlowModel(flowView: flowView, actionName: actionName)
    //    }
    
    public func beginflow(for plan: Plan, completion: @escaping (_ result: FlowResult?) -> Void) {
        guard let statusWithFlow = self.translate(planStatus: plan.getStatus()) else {return}
        let model = FlowHelperModel(initiatingFlowStatus: statusWithFlow, isInitial: isInitialFlow(plan: plan))
        let modal = FlowModal()
        modal.initialize(for: model, completion: completion)
    }
    
    /// Returns the name of the action for the plan based on its tatus
    /// if no actions are available, return nil
    ///
    /// - Parameter plan: Plan to check actions for
    /// - Returns: Action name to be displayed
    public func getActionName(for plan: Plan) -> String? {
        guard let statusWithFlow = self.translate(planStatus: plan.getStatus()) else {return nil}
        return actionNameFor(status: statusWithFlow)
    }
    
    public func getBannerTitleFor(plan: Plan) -> String? {
        guard let status = self.translate(planStatus: plan.getStatus()) else {return nil}
        return status.rawValue.convertFromCamelCase()
        switch status {
        case .SubmittedForFinalDecision:
            return ""
        case .SubmittedForReview:
            return ""
        case .StandsReview:
            return ""
        case .RecommendReady:
            return ""
        case .RecommendNotReady:
            return ""
        }
    }
    
    public func getBannerSubtitleFor(plan: Plan) -> String? {
        guard let status = self.translate(planStatus: plan.getStatus()) else {return nil}
        return status.rawValue.convertFromCamelCase()
        switch status {
        case .SubmittedForFinalDecision:
            return ""
        case .SubmittedForReview:
            return ""
        case .StandsReview:
            return ""
        case .RecommendReady:
            return ""
        case .RecommendNotReady:
            return ""
        }
    }
    
    private func isInitialFlow(plan: Plan) -> Bool {
        return plan.amendmentTypeId != -1
    }
    
    func optionsFor(model: FlowHelperModel) -> [FlowOption] {
        var options: [FlowOption] = [FlowOption]()
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            options = [.RecommendReady, .RecommendNotReady, .ChangeRequested]
        case .SubmittedForReview:
            options = [.RecommendForSubmission, .ChangeRequested]
        case .StandsReview:
            options = [ .WronglyMadeWithoutEffect, .StandsWronglyMade, .Stands]
        case .RecommendReady:
            options = [.NotApprovedFurtherWorkRequired, .Approved]
            if !model.isInitial {
                options.append(.NotApproved)
            }
        case .RecommendNotReady:
            options = [.NotApprovedFurtherWorkRequired, .Approved]
            if !model.isInitial {
                options.append(.NotApproved)
            }
        }
        
        return options
    }
    
    // if plan's amendmentTypeId is -1 (not set) is initial.
    func optionsFor(status: StatusWithFlow, isInitial: Bool?) -> [FlowOption] {
        var options: [FlowOption] = [FlowOption]()
        switch status {
        case .SubmittedForFinalDecision:
            options = [.RecommendReady, .RecommendNotReady, .ChangeRequested]
        case .SubmittedForReview:
            options = [.RecommendForSubmission, .ChangeRequested]
        case .StandsReview:
            options = [ .WronglyMadeWithoutEffect, .StandsWronglyMade, .Stands]
        case .RecommendReady:
            options = [.NotApproved, .Approved]
            if let isInitialFlow = isInitial, !isInitialFlow {
                options.append(.NotApprovedFurtherWorkRequired)
            }
        case .RecommendNotReady:
            options = [.NotApproved, .Approved]
            if let isInitialFlow = isInitial, !isInitialFlow {
                options.append(.NotApprovedFurtherWorkRequired)
            }
        }
        
        return options
    }
    
    func statusChangeNeedsToBeCommunicated(forModel model: FlowHelperModel) -> Bool {
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            return true
            
        case .SubmittedForReview:
            return true
            
        case .StandsReview:
            return true
            
        case .RecommendReady:
            if let selectedOption = model.selectedOption, selectedOption == .NotApproved || selectedOption == .NotApprovedFurtherWorkRequired {
                return true
            } else {
                return false
            }
        case .RecommendNotReady:
            if let selectedOption = model.selectedOption, selectedOption == .NotApproved || selectedOption == .NotApprovedFurtherWorkRequired {
                return true
            } else {
                return false
            }
        }
    }
    
    func statusChangeCommunicationTextFor(forModel model: FlowHelperModel) -> String? {
        // DO a switch statement on status. if status doesnt have checkbox, return nil
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            return "I have communicated"
        case .SubmittedForReview:
            return "I have communicated"
        case .StandsReview:
            return "I have communicated"
        case .RecommendReady:
            return "I have communicated"
        case .RecommendNotReady:
            return "I have communicated"
        }
    }
    
    public func translate(option: FlowOption) -> RUPStatus {
        switch option {
        case .RecommendForSubmission:
            return .RecommendForSubmission
        case .ChangeRequested:
            return .ChangeRequested
        case .RecommendReady:
            return .RecommendReady
        case .RecommendNotReady:
            return .RecommendNotReady
        case .NotApproved:
            return .NotApproved
        case .Approved:
            return .Approved
        case .NotApprovedFurtherWorkRequired:
            return .NotApprovedFurtherWorkRequired
        case .WronglyMadeWithoutEffect:
            return .WronglyMadeWithoutEffect
        case .StandsWronglyMade:
            return .WronglyMadeWithoutEffect
        case .Stands:
            return .WronglyMadeWithoutEffect
        }
    }
    
    private func actionNameFor(status: StatusWithFlow) -> String {
        switch status {
        case .SubmittedForFinalDecision:
            return "Provide Feedback"
        case .SubmittedForReview:
            return "Add Reccomendation"
        case .StandsReview:
            return "Review Amendment"
        ///////////////////////////
        case .RecommendReady:
            return "Record Descision"
        case .RecommendNotReady:
            return "Record Descision"
        }
    }
    
    private func flowViewFor(status: StatusWithFlow) -> UIView {
        switch status {
        case .SubmittedForFinalDecision:
            let view: SubmittedForFinalDescision_Flow = UIView.fromNib()
            return view
        case .SubmittedForReview:
            let view: SumittedForReview_Flow = UIView.fromNib()
            return view
        case .StandsReview:
            let view: Stands_Flow = UIView.fromNib()
            return view
        ///////////////////////////
        case .RecommendReady:
            let view: dm_Flow = UIView.fromNib()
            return view
        case .RecommendNotReady:
            let view: dm_Flow = UIView.fromNib()
            return view
        }
    }
    
    private func translate(planStatus: RUPStatus) -> StatusWithFlow? {
        switch planStatus {
        case .SubmittedForFinalDecision:
            return .SubmittedForFinalDecision
        case .SubmittedForReview:
            return .SubmittedForReview
        case .StandsReview:
            return .StandsReview
        case .RecommendReady:
            return .RecommendReady
        case .RecommendNotReady:
            return .RecommendNotReady
        default:
            return nil
        }
    }
}
