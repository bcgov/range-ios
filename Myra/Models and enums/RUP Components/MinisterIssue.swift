//
//  MinisterIssues.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class MinisterIssue: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var issueType: String = ""
    @objc dynamic var details: String = ""
    @objc dynamic var objective: String = ""
    @objc dynamic var desc: String = ""

    override class func primaryKey() -> String? {
        return "localId"
    }

    var actions = List<MinisterIssueAction>()
    var pastures = List<Pasture>()

    func set(details: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.details = details
            }
        } catch _ {
            fatalError()
        }
    }

    func set(objective: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.objective = objective
            }
        } catch _ {
            fatalError()
        }
    }

    func set(desc: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.desc = desc
            }
        } catch _ {
            fatalError()
        }
    }

    func set(issueType: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.issueType = issueType
            }
        } catch _ {
            fatalError()
        }
    }

    func addPasture(pasture: Pasture) {
        do {
            let realm = try Realm()
            try realm.write {
                self.pastures.append(pasture)
            }
        } catch _ {
            fatalError()
        }
    }

    func clearPastures() {
        do {
            let realm = try Realm()
            try realm.write {
                self.pastures.removeAll()
            }
        } catch _ {
            fatalError()
        }
    }
}
