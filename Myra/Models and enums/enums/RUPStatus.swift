//
//  RUPStatus.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

enum RUPStatus: String {
    case Pending
    case Completed
    case ClientDraft
    case Created
    case ChangeRequested
    case StaffDraft
    case WronglyMadeWithoutEffect
    case StandsWronglyMade
    case Stands
    case NotApprovedFurtherWorkRequired
    case NotApproved
    case Approved
    case SubmittedForReview
    case SubmittedForFinalDescision
    case RecommendReady
    case RecommendNotReady
    case ReadyForFinalDescision
    case LocalDraft
    case Outbox
    case Unknown
}

