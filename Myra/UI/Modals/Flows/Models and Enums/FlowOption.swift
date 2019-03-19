//
//  FlowOption.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

enum FlowOption: String {
    /* Submitted For review */
    case RecommendForSubmission
    case ChangeRequested
    
    /* Submitted For Final Descision */
    case RecommendReady
    case RecommendNotReady
    
    /* DM Flow */
    case NotApproved
    case Approved
    // if initial, do not show
    case NotApprovedFurtherWorkRequired
    
    /* stands flow */
    case WronglyMadeWithoutEffect
    case StandsWronglyMade
    case Stands
}
