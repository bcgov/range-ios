//
//  scheduleHelper.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation


class ScheduleHelper {
    static let shared = ScheduleHelper()

    private init() {}

    func calculateScheduleTotals(schedule: Schedule) {
        for entry in schedule.scheduleObjects {
            entry.calculateAUMsAndPLD()
        }
        let totalAUMs = schedule.getTotalAUMs()

    }
}
