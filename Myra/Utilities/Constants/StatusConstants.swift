//
//  StatusConstants.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-03-25.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

struct StatusConstants {
    struct Pending {
        static let serverStatus = "PENDING"
        static let serverCode = "P"
        static let description = "Agreement Holder Submitted to staff (MVP initial flow)"
        static let displayName = "Review Required"
        static let bannerTitle = "Review Required of Initial Range Use Plan"
        static let bannerDescription = "The agreement holder has submitted this initital range use plan for review. Use the Plan Actions menu to make this plan as completed."
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
        static let displayName = "Submitted to AH"
        static let bannerTitle = "Submitted to AH for Input"
        static let bannerDescription = "This range use plan has been submitted the agreement holder for input. You will be notified when a submission is received."
        static let color = Colors.Status.LightGray
    }
    
    struct ChangeRequested {
        static let serverStatus = "CHANGE_REQUESTED"
        static let serverCode = "R"
        static let description = "Staff Change Requested"
        static let displayName = "Awaiting AH Input"
        static let bannerTitle = "Submitted to AH for Changes"
        static let bannerDescription = "This range use plan has been submitted to the agreement holder for changes. You can view the details of the requested changes in the plan notes below. You will be notified when a submission is received."
        static let color = Colors.Status.DarkGray
        
        struct Flow {
            static let optionTitle = "Change Requested"
            static let optionSubtitle = "Request changes to this submission."
        }
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
        
        struct Flow {
            static let optionTitle = "Wrongly Made - Without Effect"
            static let optionSubtitle = "Submission does not meet criteria and plan to be reverted to pre-amendment state."
        }
    }
    
    struct StandsWronglyMade {
        static let serverStatus = "STANDS_WRONGLY_MADE"
        static let serverCode = "SW"
        static let description = "Minor Amendment - Wrongly Made Stands"
        static let displayName = "Wrongly Made Stands"
        static let bannerTitle = "Minor Amendment - Wrongly Made Stands"
        static let bannerDescription = "This minor amendment was deemed wrongly made but stands. This amended range use plan is now the current legal version."
        static let color = Colors.Status.Green
        
        struct Flow {
            static let optionTitle = "Wrongly Made - Without Effect"
            static let optionSubtitle = "Submission does not meet criteria and plan to be reverted to pre-amendment state."
        }
    }
    
    struct StandsReview {
        static let serverStatus = "STANDS_REVIEW"
        static let serverCode = "MSR"
        static let description = "Minor Amendment - Needs Review"
        static let displayName = "Review Amendment"
        static let bannerTitle = "Minor Amendment - Review Required"
        static let bannerDescription = "This minor amendment was submitted and will be the current legal version unless you review and the decision maker deems it wrongly made."
        static let color = Colors.Status.Yellow
        
        struct Flow {
            static let title = "Record Review Outcome"
            static let subtitle = "Record outcome of minor amendment review below."
            static let optionTitle = "Wrongly Made - Stands"
            static let optionSubtitle = "Submission does not meet criteria but minor amendment will remain in effect."
        }
    }
    
    struct Stands {
        static let serverStatus = "STANDS"
        static let serverCode = "S"
        static let description = "Minor Amendment - Stands"
        static let displayName = "Stands"
        static let bannerTitle = "Minor Amendment - Stands"
        static let bannerDescription = "This minor amendment was reviewed, meets requirements and is the current legal version."
        static let color = Colors.Status.Green
        
        struct Flow {
            static let optionTitle = "Amendment Stands"
            static let optionSubtitle = "Submission meets minor amendment criteria and will remain in effect."
        }
    }
    
    struct SubmittedForReview {
        static let serverStatus = "SUBMITTED_FOR_REVIEW"
        static let serverCode = "SR"
        static let description = "Initial/Mandatory - AH Submitted to Staff for feedback"
        static let displayName = "Provide Feedback"
        static let bannerTitle = "Provide *Initial Range Use Plan*/*Mandatory Amendment* Feedback"
        static let bannerDescription = "The agreement holder has requested your feedback for this *initial range use plan*/ *mandatory amendment *. Use the Plan Actions menu to respond to the agreement holder by selecting \"Request Changes\" or \"Recommend This Plan For Submission\"."
        static let bannerTitleInitial = "Provide Initial Range Use Plan Feedback"
        static let bannerDescriptionInitial = "The agreement holder has requested your feedback for this initial range use plan. Use the Plan Actions menu to respond to the agreement holder by selecting \"Request Changes\" or \"Recommend This Plan For Submission\"."
        static let bannerTitleMandatory = "Provide Mandatory Amendment Feedback"
        static let bannerDescriptionMandatory = "The agreement holder has requested your feedback for this mandatory amendment. Use the Plan Actions menu to respond to the agreement holder by selecting \"Request Changes\" or \"Recommend This Plan For Submission\"."
        static let color = Colors.Status.Yellow
        
        struct Flow {
            static let title = "Provide Feedback"
            static let subtitle = "Select an option below to provide feedback."
        }
    }
    
    struct SubmittedForFinalDecision {
        static let serverStatus = "SUBMITTED_FOR_FINAL_DECISION"
        static let serverCode = "SFD"
        static let description = "Initial/Mandatory - AH Submitted to Staff Final Decision"
        static let displayName = "Decision Required"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* Decision Required"
        static let bannerDescription = "This *initial range use plan*/ *mandatory amendment * has been submitted for final decision. If change are required select \"Request Changes\" from the Plan Actions menu. If the plan is ready for decision prepare your recommendation package. Once submitted to the decision maker select \"Recommend Ready\" or \"Recommend not Ready\" in the Plan Actions menu to reflect your recommendation."
        static let bannerTitleInitial = "Initial Range Use Plan Decision Required"
        static let bannerDescriptionInitial = "This initial range use plan has been submitted for final decision. If change are required select \"Request Changes\" from the Plan Actions menu. If the plan is ready for decision prepare your recommendation package. Once submitted to the decision maker select \"Recommend Ready\" or \"Recommend not Ready\" in the Plan Actions menu to reflect your recommendation."
        static let bannerTitleMandatory = "Mandatory Amendment Decision Required"
        static let bannerDescriptionMandatory = "This mandatory amendment has been submitted for final decision. If change are required select \"Request Changes\" from the Plan Actions menu. If the plan is ready for decision prepare your recommendation package. Once submitted to the decision maker select \"Recommend Ready\" or \"Recommend not Ready\" in the Plan Actions menu to reflect your recommendation."
        static let color = Colors.Status.Yellow
        
        struct Flow {
            static let title = "Add Recommendation"
            static let subtitle = "Select a recommendation to the decision maker."
        }
    }
    
    struct AwaitingConfirmation {
        static let serverStatus = "AWAITING_CONFIRMATION"
        static let serverCode = "AC"
        static let description = "Initial/Mandatory - AH Has Submitted for Final Decision and requires confirmation from other AH's"
        static let displayName = "AH Signatures Pending"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* AH Signatures Pending"
        static let bannerDescription = "This *initial range use plan*/ *mandatory amendment *'s submission process has been started and is awaiting signatures from all agreement holders. You will be notified when the submission is ready for review."
        static let bannerTitleInitial = "Initial Range Use Plan AH Signatures Pending"
        static let bannerDescriptionInitial = "This initial range use plan's submission process has been started and is awaiting signatures from all agreement holders. You will be notified when the submission is ready for review."
        static let bannerTitleMandatory = "Mandatory Amendment AH Signatures Pending"
        static let bannerDescriptionMandatory = "This mandatory amendment's submission process has been started and is awaiting signatures from all agreement holders. You will be notified when the submission is ready for review."
        static let color = Colors.Status.DarkGray
    }
    
    struct RecommendForSubmission {
        static let serverStatus = "RECOMMEND_FOR_SUBMISSION"
        static let serverCode = "RFS"
        static let description = "Initial/Mandatory - Staff Recommend AH Edits for Final Decision"
        static let displayName = "Recommended for Submission"
        static let bannerTitle = "Recommended for Submission"
        static let bannerDescription = "A staff person has provided feedback to the agreement holder that this *initial range use plan*/ *mandatory amendment * is ready for final signatures and decision. You will be notified when it has been signed and submitted."
        static let bannerTitleInitial = "Recommended for Submission"
        static let bannerDescriptionInitial = "A staff person has provided feedback to the agreement holder that this initial range use plan is ready for final signatures and decision. You will be notified when it has been signed and submitted."
        static let bannerTitleMandatory = "Recommended for Submission"
        static let bannerDescriptionMandatory = "A staff person has provided feedback to the agreement holder that this mandatory amendment is ready for final signatures and decision. You will be notified when it has been signed and submitted."
        static let color = Colors.Status.DarkGray
        
        struct Flow {
            static let optionTitle = "Recommend for Submission"
            static let optionSubtitle = "No changes needed before submission for final decision."
        }
    }
    
    struct RecommendReady {
        static let serverStatus = "RECOMMEND_READY"
        static let serverCode = "RR"
        static let description = "Initial/Mandatory - Staff Recommend Ready to DM"
        static let displayName = "Approval Recommended"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* - Recommended Ready"
        static let bannerDescription = "Staff have recommended to the decision maker that this *initial range use plan*/ *mandatory amendment * be approved. You will be notified when the decision has been made.\n\nIf the */* is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let bannerTitleInitial = "Initial Range Use Plan - Recommended Ready"
        static let bannerDescriptionInitial = "Staff have recommended to the decision maker that this initial range use plan be approved. You will be notified when the decision has been made.\nIf the initial range use plan is not approved you must notify the AH before recording the decision by tapping \"Record Descision\"."
        static let bannerTitleMandatory = "Mandatory Amendment - Recommended Ready"
        static let bannerDescriptionMandatory = "Staff have recommended to the decision maker that this mandatory amendment be approved. You will be notified when the decision has been made.\nIf the mandatory amendment is not approved you must notify the AH before recording the decision by tapping \"Record Descision\"."
        static let color = Colors.Status.DarkGray
        
        struct Flow {
            static let title = "Record Decision"
            static let subtitle = "Select an option below to record the decision."
            static let optionTitle = "Recommend Ready"
            static let optionSubtitle = "This submission is ready to be approved by decision maker."
        }
    }
    
    struct RecommendNotReady {
        static let serverStatus = "RECOMMEND_NOT_READY"
        static let serverCode = "RNR"
        static let description = "Initial/Mandatory - Staff Recommend Not Ready to DM"
        static let displayName = "Approval Not Recommended"
        static let bannerTitle = "*Initial Range Use Plan*/*Mandatory Amendment* - Recommended Not Ready"
        static let bannerDescription = "Staff have recommended to the decision maker that this *initial range use plan*/ *mandatory amendment * not be approved. You will be notified when the decision has been made.\n\nIf the */* is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let bannerTitleInitial = "Initial Range Use Plan - Recommended Not Ready"
        static let bannerDescriptionInitial = "Staff have recommended to the decision maker that this initial range use plan not be approved. You will be notified when the decision has been made.\nIf the initial range use plan is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let bannerTitleMandatory = "Mandatory Amendment - Recommended Not Ready"
        static let bannerDescriptionMandatory = "Staff have recommended to the decision maker that this mandatory amendment not be approved. You will be notified when the decision has been made.\nIf the mandatory amendment is not approved you must notify the AH before recording the decision in the Plan Actions menu."
        static let color = Colors.Status.DarkGray
        
        struct Flow {
            static let title = "Record Decision"
            static let subtitle = "Select an option below to record the decision."
            static let optionTitle = "Recommend Not Ready"
            static let optionSubtitle = "This submission is not ready to be approved by decision maker."
        }
    }
    
    struct NotApprovedFurtherWorkRequired {
        static let serverStatus = "NOT_APPROVED_FURTHER_WORK_REQUIRED"
        static let serverCode = "NF"
        static let description = "Initial/Mandatory - Not approved firther work required (Can have diff text for each)"
        static let displayName = "Changes Requested"
        static let bannerTitle = "Plan Not Approved - Further Work Required"
        static let bannerDescription = "The agreement holder has been notified that this *initial range use plan*/ *mandatory amendment * is not approved and further work is required. You will be notified when a submission is received."
        static let bannerTitleInitial = "Plan Not Approved - Further Work Required"
        static let bannerDescriptionInitial = "The agreement holder has been notified that this initial range use plan is not approved and further work is required. You will be notified when a submission is received."
        static let bannerTitleMandatory = "Plan Not Approved - Further Work Required"
        static let bannerDescriptionMandatory = "The agreement holder has been notified that this mandatory amendment is not approved and further work is required. You will be notified when a submission is received."
        static let color = Colors.Status.DarkGray
        
        struct Flow {
            static let title = "Record Decision"
            static let subtitle = "Select an option below to record the decision."
            static let optionTitle = "Not Approved - Further Work Required"
            static let optionSubtitle = "Submission is not yet ready for approval."
        }
    }
    
    struct NotApproved {
        static let serverStatus = "NOT_APPROVED"
        static let serverCode = "NA"
        static let description = "Initial/Mandatory - Not approved (Can have diff text for each)"
        static let displayName = "Not Approved"
        static let bannerTitle = "Plan Not Approved"
        static let bannerDescription = "The agreement holder has been notified that this *initial range use plan*/ *mandatory amendment * is not approved. The previously approved range use plan will be the current legal version."
        static let bannerTitleInitial = "Plan Not Approved"
        static let bannerDescriptionInitial = "The agreement holder has been notified that this initial range use plan is not approved. The previously approved range use plan will be the current legal version."
        static let bannerTitleMandatory = "Plan Not Approved"
        static let bannerDescriptionMandatory = "The agreement holder has been notified that this mandatory amendment is not approved. The previously approved range use plan will be the current legal version."
        static let color = Colors.Status.Red
        
        struct Flow {
            static let optionTitle = "Not Approved"
            static let optionSubtitle = "Further Work Required: Submission is not yet ready for approval."
        }
    }
    
    struct Approved {
        static let serverStatus = "APPROVED"
        static let serverCode = "A"
        static let description = "Initial/Mandatory - Approved (Can have diff text for each)"
        static let displayName = "Approved"
        static let bannerTitle = "Plan Approved"
        static let bannerDescription = "The agreement holder has been notified that this *initial range use plan*/ *mandatory amendment * is approved. This RUP is the current legal version."
        static let bannerTitleInitial = "Plan Approved"
        static let bannerDescriptionInitial = "The agreement holder has been notified that this initial range use plan is approved. This RUP is the current legal version."
        static let bannerTitleMandatory = "Plan Approved"
        static let bannerDescriptionMandatory = "The agreement holder has been notified that this mandatory amendment is approved. This RUP is the current legal version."
        static let color = Colors.Status.Green
        
        struct Flow {
            static let optionTitle = "Approved"
            static let optionSubtitle = "Submission approved by decision maker."
        }
    }
    
    struct LocalDraft {
        static let serverStatus = "LocalDraft"
        static let serverCode = ""
        static let description = "Initial - Staff RUP Draft Not yet syncronized"
        static let displayName = "Draft (Needs to Sync)"
        static let bannerTitle = "Local Draft (Unsynced)"
        static let bannerDescription = "This range use plan draft is currently in progress and has NOT been synced to the server. Changes to this draft may be lost. Please connect to the internet and sync the application as soon as possible using the \"Sync\" button on the homescreen."
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
