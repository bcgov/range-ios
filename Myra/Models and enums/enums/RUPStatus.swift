//
//  RUPStatus.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

enum RUPStatus: String {
    case Pending // REMOVED
    case Completed // REMOVED
    case ClientDraft
    case Created
    case ChangeRequested
    case StaffDraft
    case WronglyMadeWithoutEffect
    case StandsWronglyMade
    case Stands
    case StandsReview
    case NotApprovedFurtherWorkRequired
    case NotApproved
    case Approved
    case SubmittedForReview
    case SubmittedForFinalDecision
    case RecommendReady
    case RecommendNotReady
    case RecommendForSubmission
    case LocalDraft
    case Outbox
    case Unknown
}

