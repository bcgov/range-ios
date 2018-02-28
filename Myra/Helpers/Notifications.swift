//
//  Notifications.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let updateTableHeights = Notification.Name("updateTableHeights")
    // Pasture cells within Pastures cell
    static let updatePastureCells = Notification.Name("updatePastureCells")
    // Cell that contains Pastures
    static let updatePasturesCell = Notification.Name("updatePasturesCell")
}
