//
//  StatusColor.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class statusDescriptionModel {
    var serverStatus: String
    var serverCode: String
    var description: String
    var displayName: String
    var bannerTitle: String
    var bannerDescription: String
    var color: UIColor
    
    init(serverStatus: String, serverCode: String, description: String, displayName: String, bannerTitle: String, bannerDescription: String, color: UIColor) {
        self.serverStatus = serverStatus
        self.serverCode = serverCode
        self.description = description
        self.displayName = displayName
        self.bannerTitle = bannerTitle
        self.bannerDescription = bannerDescription
        self.color = color
    }
}

class StatusHelper {
    static func getDescription(for plan: Plan) -> statusDescriptionModel {
        let isInitial = (plan.amendmentTypeId == -1)
        let status = plan.getStatus()
        var serverStatus = ""
        var serverCode = ""
        var description = ""
        var displayName = ""
        var bannerTitle = ""
        var bannerDescription = ""
        var color = Colors.Status.LightGray
        switch status {
        case .Pending:
            serverStatus = StatusConstants.Pending.serverStatus
            serverCode = StatusConstants.Pending.serverCode
            description = StatusConstants.Pending.description
            displayName = StatusConstants.Pending.displayName
            bannerTitle = StatusConstants.Pending.bannerTitle
            bannerDescription = StatusConstants.Pending.bannerDescription
            color = StatusConstants.Pending.color
        case .Completed:
            serverStatus = StatusConstants.Completed.serverStatus
            serverCode = StatusConstants.Completed.serverCode
            description = StatusConstants.Completed.description
            displayName = StatusConstants.Completed.displayName
            bannerTitle = StatusConstants.Completed.bannerTitle
            bannerDescription = StatusConstants.Completed.bannerDescription
            color = StatusConstants.Completed.color
        case .ClientDraft:
            serverStatus = StatusConstants.Draft.serverStatus
            serverCode = StatusConstants.Draft.serverCode
            description = StatusConstants.Draft.description
            displayName = StatusConstants.Draft.displayName
            bannerTitle = StatusConstants.Draft.bannerTitle
            bannerDescription = StatusConstants.Draft.bannerDescription
            color = StatusConstants.Draft.color
        case .Created:
            serverStatus = StatusConstants.Created.serverStatus
            serverCode = StatusConstants.Created.serverCode
            description = StatusConstants.Created.description
            displayName = StatusConstants.Created.displayName
            bannerTitle = StatusConstants.Created.bannerTitle
            bannerDescription = StatusConstants.Created.bannerDescription
            color = StatusConstants.Created.color
        case .ChangeRequested:
            serverStatus = StatusConstants.ChangeRequested.serverStatus
            serverCode = StatusConstants.ChangeRequested.serverCode
            description = StatusConstants.ChangeRequested.description
            displayName = StatusConstants.ChangeRequested.displayName
            bannerTitle = StatusConstants.ChangeRequested.bannerTitle
            bannerDescription = StatusConstants.ChangeRequested.bannerDescription
            color = StatusConstants.ChangeRequested.color
        case .StaffDraft:
            serverStatus = StatusConstants.StaffDraft.serverStatus
            serverCode = StatusConstants.StaffDraft.serverCode
            description = StatusConstants.StaffDraft.description
            displayName = StatusConstants.StaffDraft.displayName
            bannerTitle = StatusConstants.StaffDraft.bannerTitle
            bannerDescription = StatusConstants.StaffDraft.bannerDescription
            color = StatusConstants.StaffDraft.color
        case .WronglyMadeWithoutEffect:
            serverStatus = StatusConstants.WronglyMadeWithoutEffect.serverStatus
            serverCode = StatusConstants.WronglyMadeWithoutEffect.serverCode
            description = StatusConstants.WronglyMadeWithoutEffect.description
            displayName = StatusConstants.WronglyMadeWithoutEffect.displayName
            bannerTitle = StatusConstants.WronglyMadeWithoutEffect.bannerTitle
            bannerDescription = StatusConstants.WronglyMadeWithoutEffect.bannerDescription
            color = StatusConstants.WronglyMadeWithoutEffect.color
        case .StandsWronglyMade:
            serverStatus = StatusConstants.StandsWronglyMade.serverStatus
            serverCode = StatusConstants.StandsWronglyMade.serverCode
            description = StatusConstants.StandsWronglyMade.description
            displayName = StatusConstants.StandsWronglyMade.displayName
            bannerTitle = StatusConstants.StandsWronglyMade.bannerTitle
            bannerDescription = StatusConstants.StandsWronglyMade.bannerDescription
            color = StatusConstants.StandsWronglyMade.color
        case .Stands:
            serverStatus = StatusConstants.Stands.serverStatus
            serverCode = StatusConstants.Stands.serverCode
            description = StatusConstants.Stands.description
            displayName = StatusConstants.Stands.displayName
            bannerTitle = StatusConstants.Stands.bannerTitle
            bannerDescription = StatusConstants.Stands.bannerDescription
            color = StatusConstants.Stands.color
        case .StandsReview:
            serverStatus = StatusConstants.StandsReview.serverStatus
            serverCode = StatusConstants.StandsReview.serverCode
            description = StatusConstants.StandsReview.description
            displayName = StatusConstants.StandsReview.displayName
            bannerTitle = StatusConstants.StandsReview.bannerTitle
            bannerDescription = StatusConstants.StandsReview.bannerDescription
            color = StatusConstants.StandsReview.color
        case .NotApprovedFurtherWorkRequired:
            serverStatus = StatusConstants.NotApprovedFurtherWorkRequired.serverStatus
            serverCode = StatusConstants.NotApprovedFurtherWorkRequired.serverCode
            description = StatusConstants.NotApprovedFurtherWorkRequired.description
            displayName = StatusConstants.NotApprovedFurtherWorkRequired.displayName
            if isInitial {
                bannerTitle = StatusConstants.NotApprovedFurtherWorkRequired.bannerTitleInitial
                bannerDescription = StatusConstants.NotApprovedFurtherWorkRequired.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.NotApprovedFurtherWorkRequired.bannerTitleMandatory
                bannerDescription = StatusConstants.NotApprovedFurtherWorkRequired.bannerDescriptionMandatory
            }
            color = StatusConstants.NotApprovedFurtherWorkRequired.color
        case .NotApproved:
            serverStatus = StatusConstants.NotApproved.serverStatus
            serverCode = StatusConstants.NotApproved.serverCode
            description = StatusConstants.NotApproved.description
            displayName = StatusConstants.NotApproved.displayName
            if isInitial {
                bannerTitle = StatusConstants.NotApproved.bannerTitleInitial
                bannerDescription = StatusConstants.NotApproved.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.NotApproved.bannerTitleMandatory
                bannerDescription = StatusConstants.NotApproved.bannerDescriptionMandatory
            }
            color = StatusConstants.NotApproved.color
        case .Approved:
            serverStatus = StatusConstants.Approved.serverStatus
            serverCode = StatusConstants.Approved.serverCode
            description = StatusConstants.Approved.description
            displayName = StatusConstants.Approved.displayName
            if isInitial {
                bannerTitle = StatusConstants.Approved.bannerTitleInitial
                bannerDescription = StatusConstants.Approved.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.Approved.bannerTitleMandatory
                bannerDescription = StatusConstants.Approved.bannerDescriptionMandatory
            }
            color = StatusConstants.Approved.color
        case .SubmittedForReview:
            serverStatus = StatusConstants.SubmittedForReview.serverStatus
            serverCode = StatusConstants.SubmittedForReview.serverCode
            description = StatusConstants.SubmittedForReview.description
            displayName = StatusConstants.SubmittedForReview.displayName
            if isInitial {
                bannerTitle = StatusConstants.SubmittedForReview.bannerTitleInitial
                bannerDescription = StatusConstants.SubmittedForReview.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.SubmittedForReview.bannerTitleMandatory
                bannerDescription = StatusConstants.SubmittedForReview.bannerDescriptionMandatory
            }
            color = StatusConstants.SubmittedForReview.color
        case .SubmittedForFinalDecision:
            serverStatus = StatusConstants.SubmittedForFinalDecision.serverStatus
            serverCode = StatusConstants.SubmittedForFinalDecision.serverCode
            description = StatusConstants.SubmittedForFinalDecision.description
            displayName = StatusConstants.SubmittedForFinalDecision.displayName
            if isInitial {
                bannerTitle = StatusConstants.SubmittedForFinalDecision.bannerTitleInitial
                bannerDescription = StatusConstants.SubmittedForFinalDecision.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.SubmittedForFinalDecision.bannerTitleMandatory
                bannerDescription = StatusConstants.SubmittedForFinalDecision.bannerDescriptionMandatory
            }
            color = StatusConstants.SubmittedForFinalDecision.color
        case .RecommendReady:
            serverStatus = StatusConstants.RecommendReady.serverStatus
            serverCode = StatusConstants.RecommendReady.serverCode
            description = StatusConstants.RecommendReady.description
            displayName = StatusConstants.RecommendReady.displayName
            if isInitial {
                bannerTitle = StatusConstants.RecommendReady.bannerTitleInitial
                bannerDescription = StatusConstants.RecommendReady.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.RecommendReady.bannerTitleMandatory
                bannerDescription = StatusConstants.RecommendReady.bannerDescriptionMandatory
            }
            color = StatusConstants.RecommendReady.color
        case .RecommendNotReady:
            serverStatus = StatusConstants.RecommendNotReady.serverStatus
            serverCode = StatusConstants.RecommendNotReady.serverCode
            description = StatusConstants.RecommendNotReady.description
            displayName = StatusConstants.RecommendNotReady.displayName
            if isInitial {
                bannerTitle = StatusConstants.RecommendNotReady.bannerTitleInitial
                bannerDescription = StatusConstants.RecommendNotReady.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.RecommendNotReady.bannerTitleMandatory
                bannerDescription = StatusConstants.RecommendNotReady.bannerDescriptionMandatory
            }
            color = StatusConstants.RecommendNotReady.color
        case .RecommendedForSubmission:
            serverStatus = StatusConstants.RecommendForSubmission.serverStatus
            serverCode = StatusConstants.RecommendForSubmission.serverCode
            description = StatusConstants.RecommendForSubmission.description
            displayName = StatusConstants.RecommendForSubmission.displayName
            if isInitial {
                bannerTitle = StatusConstants.RecommendForSubmission.bannerTitleInitial
                bannerDescription = StatusConstants.RecommendForSubmission.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.RecommendForSubmission.bannerTitleMandatory
                bannerDescription = StatusConstants.RecommendForSubmission.bannerDescriptionMandatory
            }
            color = StatusConstants.RecommendForSubmission.color
        case .LocalDraft:
            serverStatus = StatusConstants.LocalDraft.serverStatus
            serverCode = StatusConstants.LocalDraft.serverCode
            description = StatusConstants.LocalDraft.description
            displayName = StatusConstants.LocalDraft.displayName
            bannerTitle = StatusConstants.LocalDraft.bannerTitle
            bannerDescription = StatusConstants.LocalDraft.bannerDescription
            color = StatusConstants.LocalDraft.color
        case .Outbox:
            serverStatus = StatusConstants.Outbox.serverStatus
            serverCode = StatusConstants.Outbox.serverCode
            description = StatusConstants.Outbox.description
            displayName = StatusConstants.Outbox.displayName
            bannerTitle = StatusConstants.Outbox.bannerTitle
            bannerDescription = StatusConstants.Outbox.bannerDescription
            color = StatusConstants.Outbox.color
        case .Unknown:
            color = UIColor.purple
        case .AwaitingConfirmation:
            serverStatus = StatusConstants.AwaitingConfirmation.serverStatus
            serverCode = StatusConstants.AwaitingConfirmation.serverCode
            description = StatusConstants.AwaitingConfirmation.description
            displayName = StatusConstants.AwaitingConfirmation.displayName
            if isInitial {
                bannerTitle = StatusConstants.AwaitingConfirmation.bannerTitleInitial
                bannerDescription = StatusConstants.AwaitingConfirmation.bannerDescriptionInitial
            } else {
                bannerTitle = StatusConstants.AwaitingConfirmation.bannerTitleMandatory
                bannerDescription = StatusConstants.AwaitingConfirmation.bannerDescriptionMandatory
            }
            color = StatusConstants.AwaitingConfirmation.color
        }
        return statusDescriptionModel(serverStatus: serverStatus, serverCode: serverCode, description: description, displayName: displayName, bannerTitle: bannerTitle, bannerDescription: bannerDescription, color: color)
    }
    
    static func getColor(for plan: Plan) -> UIColor {
        return getDescription(for: plan).color
    }
    
    static func getServerCode(for status: RUPStatus) -> String {
        var serverCode = ""
        switch status {
        case .Pending:
            serverCode = StatusConstants.Pending.serverCode
        case .Completed:
            serverCode = StatusConstants.Completed.serverCode
        case .ClientDraft:
            serverCode = StatusConstants.Draft.serverCode
        case .Created:
            serverCode = StatusConstants.Created.serverCode
        case .ChangeRequested:
            serverCode = StatusConstants.ChangeRequested.serverCode
        case .StaffDraft:
            serverCode = StatusConstants.StaffDraft.serverCode
        case .WronglyMadeWithoutEffect:
            serverCode = StatusConstants.WronglyMadeWithoutEffect.serverCode
        case .StandsWronglyMade:
            serverCode = StatusConstants.StandsWronglyMade.serverCode
        case .Stands:
            serverCode = StatusConstants.Stands.serverCode
        case .StandsReview:
            serverCode = StatusConstants.StandsReview.serverCode
        case .NotApprovedFurtherWorkRequired:
            serverCode = StatusConstants.NotApprovedFurtherWorkRequired.serverCode
        case .NotApproved:
            serverCode = StatusConstants.NotApproved.serverCode
        case .Approved:
            serverCode = StatusConstants.Approved.serverCode
        case .SubmittedForReview:
            serverCode = StatusConstants.SubmittedForReview.serverCode
        case .SubmittedForFinalDecision:
            serverCode = StatusConstants.SubmittedForFinalDecision.serverCode
        case .RecommendReady:
            serverCode = StatusConstants.RecommendReady.serverCode
        case .RecommendNotReady:
            serverCode = StatusConstants.RecommendNotReady.serverCode
        case .RecommendedForSubmission:
            serverCode = StatusConstants.RecommendForSubmission.serverCode
        case .LocalDraft:
            serverCode = StatusConstants.LocalDraft.serverCode
        case .Outbox:
            serverCode = StatusConstants.Outbox.serverCode
        case .Unknown:
            serverCode = ""
        case .AwaitingConfirmation:
            serverCode = StatusConstants.AwaitingConfirmation.serverCode
        }
        return serverCode
    }
}
