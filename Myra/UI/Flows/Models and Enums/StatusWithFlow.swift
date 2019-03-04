//
//  StatusWithFlow.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

enum StatusWithFlow: String {
    case SubmittedForFinalDecision
    case SubmittedForReview
    case StandsReview
    
    // DM Flows
    case RecommendReady
    case RecommendNotReady
}
