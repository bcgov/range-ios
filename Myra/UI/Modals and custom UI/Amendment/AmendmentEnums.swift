//
//  AmendmentEnums.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-31.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

// Action options shown in create page.
enum PlanAction {
    case UpdateAmendment
    case ApproveAmendment
    case ReturnToAgreementHolder
    case FinalReview
    case UpdateStatus
    case CreateMandatoryAmendment
    case CancelAmendment
    case PrepareForSubmission
}

// Amendment Flow mode
enum AmendmentFlowMode {
    case Create // Amendment submission flow
    case Initial
    case ReturnToAgreementHolder // new
    case Mandatory // if amenetment type contains mandatory key word AND plan status is not ReccomentReady
    case Minor // if amenetment type contains minor key word
    case FinalReview // if plan has amendment type
}

// Amendment Flow Options
enum AmendmentChangeType {
    case Completed
    
    // Minor
    case Stands
    case WronglyMadeStands
    case WronglyMadeNoEffect
    /////////
    
    // Mandatory/ Initial
    case Ready // in response to a review request
    case NotReady // in response to a review request
    
    case NotApprovedFurtherWorkRequired // Descision maker outcomes
    case NotApproved // Descision maker outcomes
    case Approved // Descision maker outcomes
    
    case ChangeRequested
    case RequestAgreementHolderInput
    case RequestAgreementHolderEsignature // Staff requests ah signature
}

struct AmendmentConstants {
}
