//
//  SyncDate.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class SyncDate: Object {
    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    @objc dynamic var fullSync: Date?
    @objc dynamic var refDownload: Date?

    func timeSince() -> String {
        var reponse = "Unknown"
        guard let lastFull = fullSync else {
            return reponse
        }
        let calendar = Calendar.current
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastFull)

        let hours = timeInterval.hours
        let minutes = timeInterval.minutes
        let seconds = timeInterval.seconds

        if hours < 1 {
            if minutes < 1 {
                // show seconds
                if seconds < 5 {
                    reponse = "Just now"
                } else {
                    reponse = "\(seconds) seconds ago"
                }
            } else {
                // show minutes
                if minutes == 1 {
                    reponse = "\(minutes) minute ago"
                } else {
                    reponse = "\(minutes) minutes ago"
                }
            }
        } else {
            if hours > 24 {
                // show days
                let components = calendar.dateComponents([.day], from: lastFull, to: now)
                if let days = components.day {
                    if days == 1 {
                        reponse = "\(days) day ago"
                    } else {
                        reponse = "\(days) days ago"
                    }
                }
            } else {
                // show hours
                if hours == 1  {
                    if minutes == 1 {
                        reponse = "\(hours) hour and \(minutes) minute ago"
                    } else {
                        reponse = "\(hours) hour and \(minutes) minutes ago"
                    }
                } else {
                    if minutes == 1 {
                        reponse = "\(hours) hours and \(minutes) minute ago"
                    } else {
                        reponse = "\(hours) hours and \(minutes) minutes ago"
                    }
                }
            }
        }
        return reponse
    }
}
