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

     // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var issueType: String = ""
    @objc dynamic var issueTypeID: Int = -1
    @objc dynamic var details: String = ""
    @objc dynamic var objective: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var identified: Bool = false
    
    var actions = List<MinisterIssueAction>()
    var pastures = List<Pasture>()

    // MARK: Initializations
    convenience init(json: JSON, plan: Plan) {
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

        let pastureIds = json["pastures"]
        for (_, id) in pastureIds {
            if let pastureId = id.int {
                for pasture in plan.pastures where  pasture.remoteId == pastureId {
                    self.pastures.append(pasture)
                }
            }
        }

        let actions = json["ministerIssueActions"]

        for action in actions {
            self.actions.append(MinisterIssueAction(json: action.1))
        }
    }

    // MARK: Deletion
    func deleteSubObjects() {
        for element in self.actions {
            RealmRequests.deleteObject(element)
        }
    }

    // MARK: Getters
    func getPastureIds() -> [Int] {
        var pastureIds: [Int] = [Int]()
        for pasture in pastures {
            pastureIds.append(pasture.remoteId)
        }
        return pastureIds
    }

    // MARK: Setters
    func set(details: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.details = details
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func set(objective: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.objective = objective
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func set(desc: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.desc = desc
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func set(issueType: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.issueType = issueType
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func addPasture(pasture: Pasture) {
        do {
            let realm = try Realm()
            try realm.write {
                self.pastures.append(pasture)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func removePastures() {
        do {
            let realm = try Realm()
            try realm.write {
                self.pastures.removeAll()
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func addAction(type: MinisterIssueActionType, name: String) {
        let new = MinisterIssueAction()
        new.actionType = name
        new.actionTypeID = type.id
        if type.name.lowercased() == "other" {
            new.otherActionTypeName = name
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.actions.append(new)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.remoteId = id
            }
        } catch {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        return !(self.issueTypeID == -1 || self.details.isEmpty || self.objective.isEmpty || !self.identified)
    }

    // MARK: Export
    func toDictionary() -> [String:Any] {
        return [
            "detail": self.details,
            "objective": self.objective,
            "identified": identified,
            "pastures" : getPastureIds(),
            "issueTypeId": self.issueTypeID,
        ]
    }

    func copy() -> MinisterIssue {
        let new = MinisterIssue()
        new.remoteId = self.remoteId
        new.issueType = self.issueType
        new.issueTypeID = self.issueTypeID
        new.details = self.details
        new.objective = self.objective
        new.desc = self.desc
        new.identified = self.identified

        for object in self.actions {
            new.actions.append(object.copy())
        }

        for object in self.pastures {
            new.pastures.append(object.clone())
        }
        return new
    }
}
