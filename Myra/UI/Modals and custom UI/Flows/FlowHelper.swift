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
    
    func getTitleFor(option: FlowOption) -> String {
        switch option {
        case .RecommendForSubmission:
            return StatusConstants.RecommendForSubmission.Flow.optionTitle
        case .ChangeRequested:
            return StatusConstants.ChangeRequested.Flow.optionTitle
        case .RecommendReady:
            return StatusConstants.RecommendReady.Flow.optionTitle
        case .RecommendNotReady:
            return StatusConstants.RecommendNotReady.Flow.optionTitle
        case .NotApproved:
            return StatusConstants.NotApproved.Flow.optionTitle
        case .Approved:
            return StatusConstants.Approved.Flow.optionTitle
        case .NotApprovedFurtherWorkRequired:
            return StatusConstants.NotApprovedFurtherWorkRequired.Flow.optionTitle
        case .WronglyMadeWithoutEffect:
            return StatusConstants.WronglyMadeWithoutEffect.Flow.optionTitle
        case .StandsWronglyMade:
            return StatusConstants.StandsWronglyMade.Flow.optionTitle
        case .Stands:
            return StatusConstants.Stands.Flow.optionTitle
        }
    }
    
    func getSubtitleFor(option: FlowOption) -> String {
        switch option {
        case .RecommendForSubmission:
            return StatusConstants.RecommendForSubmission.Flow.optionSubtitle
        case .ChangeRequested:
            return StatusConstants.ChangeRequested.Flow.optionSubtitle
        case .RecommendReady:
            return StatusConstants.RecommendReady.Flow.optionSubtitle
        case .RecommendNotReady:
            return StatusConstants.RecommendNotReady.Flow.optionSubtitle
        case .NotApproved:
            return StatusConstants.NotApproved.Flow.optionSubtitle
        case .Approved:
            return StatusConstants.Approved.Flow.optionSubtitle
        case .NotApprovedFurtherWorkRequired:
            return StatusConstants.NotApprovedFurtherWorkRequired.Flow.optionSubtitle
        case .WronglyMadeWithoutEffect:
            return StatusConstants.WronglyMadeWithoutEffect.Flow.optionSubtitle
        case .StandsWronglyMade:
            return StatusConstants.StandsWronglyMade.Flow.optionSubtitle
        case .Stands:
            return StatusConstants.Stands.Flow.optionSubtitle
        }
    }
    
    func statusChangeNeedsToBeCommunicated(forModel model: FlowHelperModel) -> Bool {
        if let option = model.selectedOption, statusChangeCommunicationTextFor(option: option) != nil {
            return true
        } else {
            return false
        }
    }
    
    func statusChangeCommunicationTextFor(option: FlowOption) -> String? {
        // if status doesnt have checkbox, return nil
        
        // Turns out we want the same text for all of them anyway
        switch option {
        case .ChangeRequested:
            return "I have have communicated with agreement holder about this update and wish to change status"
        case .NotApproved:
            return "I have have communicated with agreement holder about this update and wish to change status"
        case .NotApprovedFurtherWorkRequired:
            return "I have have communicated with agreement holder about this update and wish to change status"
        case .WronglyMadeWithoutEffect:
            return "I have have communicated with agreement holder about this update and wish to change status"
        case .StandsWronglyMade:
            return "I have have communicated with agreement holder about this update and wish to change status"
        default:
            return nil
        }
    }
   
    public func translate(option: FlowOption) -> RUPStatus {
        switch option {
        case .RecommendForSubmission:
            return .RecommendedForSubmission
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
            return StatusConstants.SubmittedForFinalDecision.Flow.title
        case .SubmittedForReview:
            return StatusConstants.SubmittedForReview.Flow.title
        case .StandsReview:
            return StatusConstants.StandsReview.Flow.title
        ///////////////////////////
        case .RecommendReady:
            return StatusConstants.RecommendReady.Flow.title
        case .RecommendNotReady:
            return StatusConstants.RecommendNotReady.Flow.title
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
