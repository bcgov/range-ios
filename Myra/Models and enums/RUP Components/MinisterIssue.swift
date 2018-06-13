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
import SwiftyJSON

class MinisterIssue: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var issueType: String = ""
    @objc dynamic var issueTypeID: Int = -1
    @objc dynamic var details: String = ""
    @objc dynamic var objective: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var identified: Bool = false

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

    func addAction(type: MinisterIssueActionType) {
        let new = MinisterIssueAction()
        new.actionType = type.name
        new.actionTypeID = type.id
        do {
            let realm = try Realm()
            try realm.write {
                self.actions.append(new)
            }
        } catch _ {
            fatalError()
        }
    }

    func toDictionary() -> [String:Any] {
        return [
            "detail": self.details,
            "objective": self.objective,
            "identified": true,
            "issueTypeId": self.issueTypeID,
        ]
    }

    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let typeName = json["ministerIssueType"]["name"].string {
            self.issueType = typeName
        }

        if let issueTypeId = json["issueTypeId"].int {
            self.issueTypeID = issueTypeId
        }

        if let objective = json["objective"].string {
            self.objective = objective
        }

        if let detail = json["detail"].string {
            self.details = detail
        }

        if let identified = json["identified"].bool {
            self.identified = identified
        }

        let actions = json["ministerIssueActions"]

        for action in actions {
            self.actions.append(MinisterIssueAction(json: action.1))
        }
    }
}
