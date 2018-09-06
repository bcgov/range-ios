//
//  TimeInterval.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension TimeInterval {
    var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }

    var seconds: Int {
        return Int(self) % 60
    } 

    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }

    var hours: Int {
        return Int(self) / 3600
    }

    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}
