//
//  Notifications.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let screenOrientationChanged = Notification.Name("screenOrientationChanged")
    static let usernameUpdatedInSettings = Notification.Name("usernameUpdatedInSettings")
    
    static let formScrolled = Notification.Name("formScrolled")
    static let formEndedStrolling = Notification.Name("formEndedStrolling")
    
    static let planChanged = Notification.Name("planChanged")
    static let planClosed = Notification.Name("planClosed")
    
    static let flowOptionSelectionChanged = Notification.Name("flowOptionSelectionChanged")
}
