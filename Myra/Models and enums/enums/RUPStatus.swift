//
//  RUPStatus.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

enum RUPStatus: String {
    case LocalDraft
    case Pending
    case Completed
    case Outbox
    case Created
    case ChangeRequested
    case ClientDraft
    case Unknown
}
