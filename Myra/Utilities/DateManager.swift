//
//  DateManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
class DateManager {

    static func toString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }

    static func toStringNoYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: date)
    }

    static func from(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.date(from: string)!
    }

    static func fromUTC(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale.init(identifier: "en_CA")
        return dateFormatter.date(from: string)!
    }

    static func toUTC(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_CA")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSXXXXX"
        return formatter.string(from: date)
    }

    static func daysBetween(date1: Date, date2: Date) -> Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return(components.day ?? -1)
    }

    static func update(date: Date, toYear: Int) -> Date {
        var component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        component.year = toYear
        return Calendar.current.date(from: component)!
    }

    static func fiveYearsLater(date: Date) -> Date {
        var component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        component.year = component.year! + 5
        return Calendar.current.date(from: component)!
    }

}
