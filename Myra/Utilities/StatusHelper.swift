//
//  StatusColor.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

struct StatusConstants {
    struct Pending {
        static let serverStatus = "PENDING"
        static let serverCode = "P"
        static let description = "Agreement Holder Submitted to staff (MVP initial flow)"
        static let displayName = "Review Required"
        static let bannerTitle = "Review Required of Initial Range Use Plan"
        static let bannerDescription = "The agreement holder has submitted this intital range use plan for review. Use the Plan Actions menu to make this plan as completed."
        static let color = Colors.Status.Yellow
    }
    
    struct Completed {
        static let serverStatus = "COMPLETED"
        static let serverCode = "O"
        static let description = "Basically Approved *WILL BE REMOVED*"
        static let displayName = "Approved by DM"
        static let bannerTitle = "This Range Use Plan has been approved"
        static let bannerDescription = "This initial range use plan has been approved by the decision maker."
        static let color = Colors.Status.Green
    }
    
    struct Draft {
        static let serverStatus = "DRAFT"
        static let serverCode = "D"
        static let description = "AH Draft in Progress"
        static let displayName = "Draft in Progress"
        static let bannerTitle = "Draft In Progress by AH"
        static let bannerDescription = "This range use plan draft is being worked on by the agreement holder. Some content may not be visible until agreement holder has submitted it to Range Staff."
        static let color = Colors.Status.LightGray
    }
    
    struct Created {
        static let serverStatus = "CREATED"
        static let serverCode = "C"
        static let description = "iOS Submited to AH"
        static let displayName = "Add Content to RUP"
        static let bannerTitle = "Submitted to AH for Input"
        static let bannerDescription = "This range use plan has been submitted the agreement holder for input. You will be notified when a submission is received."
        static let color = Colors.Status.LightGray
    }
    
    /* INCOMPLETE FROM HERE */
    struct ChangeRequested {
        static let serverStatus = "CHANGE_REQUESTED"
        static let serverCode = "R"
        static let description = "Staff Change Requested"
        static let displayName = "Awaiting AH Input"
        static let bannerTitle = "Submitted to AH for Changes"
        static let bannerDescription = "This range use plan has been submitted to the agreement holder for changes. You can view the details of the requested changes in the plan notes below. You will be notified when a submission is received."
        static let color = Colors.Status.DarkGray
    }
    
    struct StaffDraft {
        static let serverStatus = "STAFF_DRAFT"
        static let serverCode = "SD"
        static let description = "Staff Draft (Synced from iOS)"
        static let displayName = "Staff Draft"
        static let bannerTitle = "Staff Draft (Synced from iOS)"
        static let bannerDescription = "This range use plan draft is currently in progress and synced to the server. Use the \"Save\" button to save your draft or \"Submit to Client\" when ready for the agreement holder to add conent."
        static let color = Colors.Status.LightGray
    }
    
    struct WronglyMadeWithoutEffect {
        static let serverStatus = "WRONGLY_MADE_WITHOUT_EFFECT"
        static let serverCode = "WM"
        static let description = "Minor Amendment - Wrongly Made Without Effect"
        static let displayName = "Wrongly Made Without Effect"
        static let bannerTitle = "Minor Amendment - Wrongly Made Without Effect"
        static let bannerDescription = "This range use plan minor amendment was wrongly made and is without effect. The previously approved range use plan will be the current legal version."
        static let color = Colors.Status.Red
    }
    
    struct StandsWronglyMade {
        static let serverStatus = "STANDS_WRONGLY_MADE"
        static let serverCode = "SW"
        static let description = "Minor Amendment - Wrongly Made Stands"
        static let displayName = "Wrongly Made Stands"
        static let bannerTitle = "Minor Amendment - Wrongly Made Stands"
        static let bannerDescription = "This minor amendment was deemed wrongly made but stands. This amended range use plan is now the current legal version."
        static let color = Colors.Status.Green
    }
    
    struct StandsReview {
        static let serverStatus = "STANDS_REVIEW"
        static let serverCode = "MSR"
        static let description = "Minor Amendment - Needs Review"
        static let displayName = "Review Amendment"
        static let bannerTitle = "Minor Amendment - Review Required"
        static let bannerDescription = "This minor amendment was submitted and will be the current legal version unless you review and the decision maker deems it wrongly made."
        static let color = Colors.Status.Yellow
    }
    
    struct Stands {
        static let serverStatus = "STANDS"
        static let serverCode = "S"
        static let description = "Minor Amendment - Stands"
        static let displayName = "Stands"
        static let bannerTitle = "Minor Amendment - Stands"
        static let bannerDescription = "This minor amendment was reviewed, meets requirements and is the current legal version."
        static let color = Colors.Status.Green
    }
    
    struct SubmittedForReview {
        static let serverStatus = "SUBMITTED_FOR_REVIEW"
        static let serverCode = "SR"
        static let description = "Initial/Mandatory - AH Submitted to Staff for feedback"
        static let displayName = "Provide Feedback"
        static let bannerTitle = "Provide *Initial Range Use Plan*/*Mandatory Amendment* Feedback"
        static let bannerDescription = "The agreement holder has requested your feedback for this *intial range use plan*/ *mandatory amendment *. Use the Plan Actions menu to respond to the agreement holder by selecting \"Request Changes\" or \"Recommend This Plan For Submission\"."
        static let color = Colors.Status.Yellow
    }
    
    struct SubmittedForFinalDecision {
        static let serverStatus = "SUBMITTED_FOR_FINAL_DECISION"
        static let serverCode = "SFD"
        static let description = "Initial/Mandatory - AH Submitted to Staff Final Decision"
        static let displayName = "Decision Required"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* Decision Required"
        static let bannerDescription = "This *intial range use plan*/ *mandatory amendment * has been submitted for final decision. If change are required select \"Request Changes\" from the Plan Actions menu. If the plan is ready for decision prepare your recommendation package. Once submitted to the decision maker select \"Recommend Ready\" or \"Recommend not Ready\" in the Plan Actions menu to reflect your recommendation."
        static let color = Colors.Status.Yellow
    }
    
    struct AwaitingConfirmation {
        static let serverStatus = "AWAITING_CONFIRMATION"
        static let serverCode = "AC"
        static let description = "Initial/Mandatory - AH Has Submitted for Final Decision and requires confirmation from other AH's"
        static let displayName = "AH Signatures Pending"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* AH Signatures Pending"
        static let bannerDescription = "This *intial range use plan*/ *mandatory amendment *'s submission process has been started and is awaiting signatures from all agreement holders. You will be notified when the submission is ready for review."
        static let color = Colors.Status.DarkGray
    }
    
    struct RecommendForSubmission {
        static let serverStatus = "RECOMMEND_FOR_SUBMISSION"
        static let serverCode = "RFS"
        static let description = "Initial/Mandatory - Staff Recommend AH Edits for Final Decision"
        static let displayName = "Recommended for Submission"
        static let bannerTitle = "Recommended for Submission"
        static let bannerDescription = "A staff person has provided feedback to the agreement holder that this *intial range use plan*/ *mandatory amendment * is ready for final signatures and decision. You will be notified when it has been signed and submitted."
        static let color = Colors.Status.DarkGray
    }
    
    struct RecommendReady {
        static let serverStatus = "RECOMMEND_READY"
        static let serverCode = "RR"
        static let description = "Initial/Mandatory - Staff Recommend Ready to DM"
        static let displayName = "Approval Recommended"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* - Recommended Ready"
        static let bannerDescription = "Staff have recommended to the decision maker that this *intial range use plan*/ *mandatory amendment * be approved. You will be notified when the decision has been made.\n\nIf the */* is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let color = Colors.Status.DarkGray
    }
    
    struct RecommendNotReady {
        static let serverStatus = "RECOMMEND_NOT_READY"
        static let serverCode = "RNR"
        static let description = "Initial/Mandatory - Staff Recommend Not Ready to DM"
        static let displayName = "Approval Not Recommended"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* - Recommended Not Ready"
        static let bannerDescription = "Staff have recommended to the decision maker that this *intial range use plan*/ *mandatory amendment * not be approved. You will be notified when the decision has been made.\n\nIf the */* is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let color = Colors.Status.DarkGray
    }
    
    struct NotApprovedFurtherWorkRequired {
        static let serverStatus = "NOT_APPROVED_FURTHER_WORK_REQUIRED"
        static let serverCode = "NF"
        static let description = "Initial/Mandatory - Not approved firther work required (Can have diff text for each)"
        static let displayName = "Changes Requested"
        static let bannerTitle = "Plan Not Approved - Further Work Required"
        static let bannerDescription = "The agreement holder has been notified that this *intial range use plan*/ *mandatory amendment * is not approved and further work is required. You will be notified when a submission is received."
        static let color = Colors.Status.DarkGray
    }
    
    struct NotApproved {
        static let serverStatus = "NOT_APPROVED"
        static let serverCode = "NA"
        static let description = "Initial/Mandatory - Not approved (Can have diff text for each)"
        static let displayName = "Not Approved"
        static let bannerTitle = "Plan Not Approved"
        static let bannerDescription = "The agreement holder has been notified that this *intial range use plan*/ *mandatory amendment * is not approved. The previously approved range use plan will be the current legal version."
        static let color = Colors.Status.Red
    }
    
    struct Approved {
        static let serverStatus = "APPROVED"
        static let serverCode = "A"
        static let description = "Initial/Mandatory - Approved (Can have diff text for each)"
        static let displayName = "Approved"
        static let bannerTitle = "Plan Approved"
        static let bannerDescription = "The agreement holder has been notified that this *intial range use plan*/ *mandatory amendment * is approved. This RUP is the current legal version."
        static let color = Colors.Status.Green
    }
    
    struct LocalDraft {
        static let serverStatus = "LocalDraft"
        static let serverCode = ""
        static let description = "Initial - Staff RUP Draft Not yet syncronized"
        static let displayName = "Draft (Needs to Sync)"
        static let bannerTitle = "Submitted to AH for Input"
        static let bannerDescription = "This range use plan has been submitted the agreement holder for input. You will be notified when a submission is received."
        static let color = Colors.Status.DarkGray
    }
    
    struct Outbox {
        static let serverStatus = "Outbox"
        static let serverCode = ""
        static let description = "Initial Submission - sent to Agreement Holder not yet synchronized"
        static let displayName = "Ready to Send (Sync Required)"
        static let bannerTitle = "Ready to Send (Sync Required)"
        static let bannerDescription = "This initial plan has not yet been synced to the server OR sent the agreement holder. Changes to this submission may be lost. Please connect to the internet and sync the application as soon as possible using the \"Sync\" button on the homescreen."
        static let color = Colors.Status.Yellow
    }
}

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
    static func getDescription(for status: RUPStatus) -> statusDescriptionModel {
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
            bannerTitle = StatusConstants.NotApprovedFurtherWorkRequired.bannerTitle
            bannerDescription = StatusConstants.NotApprovedFurtherWorkRequired.bannerDescription
            color = StatusConstants.NotApprovedFurtherWorkRequired.color
        case .NotApproved:
            serverStatus = StatusConstants.NotApproved.serverStatus
            serverCode = StatusConstants.NotApproved.serverCode
            description = StatusConstants.NotApproved.description
            displayName = StatusConstants.NotApproved.displayName
            bannerTitle = StatusConstants.NotApproved.bannerTitle
            bannerDescription = StatusConstants.NotApproved.bannerDescription
            color = StatusConstants.NotApproved.color
        case .Approved:
            serverStatus = StatusConstants.Approved.serverStatus
            serverCode = StatusConstants.Approved.serverCode
            description = StatusConstants.Approved.description
            displayName = StatusConstants.Approved.displayName
            bannerTitle = StatusConstants.Approved.bannerTitle
            bannerDescription = StatusConstants.Approved.bannerDescription
            color = StatusConstants.Approved.color
        case .SubmittedForReview:
            serverStatus = StatusConstants.SubmittedForReview.serverStatus
            serverCode = StatusConstants.SubmittedForReview.serverCode
            description = StatusConstants.SubmittedForReview.description
            displayName = StatusConstants.SubmittedForReview.displayName
            bannerTitle = StatusConstants.SubmittedForReview.bannerTitle
            bannerDescription = StatusConstants.SubmittedForReview.bannerDescription
            color = StatusConstants.SubmittedForReview.color
        case .SubmittedForFinalDecision:
            serverStatus = StatusConstants.SubmittedForFinalDecision.serverStatus
            serverCode = StatusConstants.SubmittedForFinalDecision.serverCode
            description = StatusConstants.SubmittedForFinalDecision.description
            displayName = StatusConstants.SubmittedForFinalDecision.displayName
            bannerTitle = StatusConstants.SubmittedForFinalDecision.bannerTitle
            bannerDescription = StatusConstants.SubmittedForFinalDecision.bannerDescription
            color = StatusConstants.SubmittedForFinalDecision.color
        case .RecommendReady:
            serverStatus = StatusConstants.RecommendReady.serverStatus
            serverCode = StatusConstants.RecommendReady.serverCode
            description = StatusConstants.RecommendReady.description
            displayName = StatusConstants.RecommendReady.displayName
            bannerTitle = StatusConstants.RecommendReady.bannerTitle
            bannerDescription = StatusConstants.RecommendReady.bannerDescription
            color = StatusConstants.RecommendReady.color
        case .RecommendNotReady:
            serverStatus = StatusConstants.RecommendNotReady.serverStatus
            serverCode = StatusConstants.RecommendNotReady.serverCode
            description = StatusConstants.RecommendNotReady.description
            displayName = StatusConstants.RecommendNotReady.displayName
            bannerTitle = StatusConstants.RecommendNotReady.bannerTitle
            bannerDescription = StatusConstants.RecommendNotReady.bannerDescription
            color = StatusConstants.RecommendNotReady.color
        case .RecommendForSubmission:
            serverStatus = StatusConstants.RecommendForSubmission.serverStatus
            serverCode = StatusConstants.RecommendForSubmission.serverCode
            description = StatusConstants.RecommendForSubmission.description
            displayName = StatusConstants.RecommendForSubmission.displayName
            bannerTitle = StatusConstants.RecommendForSubmission.bannerTitle
            bannerDescription = StatusConstants.RecommendForSubmission.bannerDescription
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
        }
        return statusDescriptionModel(serverStatus: serverStatus, serverCode: serverCode, description: description, displayName: displayName, bannerTitle: bannerTitle, bannerDescription: bannerDescription, color: color)
    }
    
    static func getColor(for status: RUPStatus) -> UIColor {
        return getDescription(for: status).color
    }
}
