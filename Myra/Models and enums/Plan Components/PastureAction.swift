//
//  PastureAction.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class PastureAction: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var details: String = ""
    @objc dynamic var action: String = ""

    @objc dynamic var noGrazeOutSelected: Bool = false
    @objc dynamic var noGrazeInDay: Int = 1
    @objc dynamic var noGrazeInMonth: Int = 1
    @objc dynamic var noGrazeInSelected: Bool = false
    @objc dynamic var noGrazeOutDay: Int = 1
    @objc dynamic var noGrazeOutMonth: Int = 12

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }
        if let actionTypeJSON = json["actionType"].dictionaryObject, let actionTypeName = actionTypeJSON["name"] as? String {
            action = actionTypeName
        }

        if let noGrazeStartDay = json["noGrazeStartDay"].int, let noGrazeStartMonth = json["noGrazeStartMonth"].int {
            self.noGrazeInDay = noGrazeStartDay
            self.noGrazeInMonth = noGrazeStartMonth
            self.noGrazeInSelected = true
        }

        if let noGrazeEndDay = json["noGrazeEndDay"].int, let noGrazeEndMonth = json["noGrazeEndMonth"].int {
            self.noGrazeOutDay = noGrazeEndDay
            self.noGrazeOutMonth = noGrazeEndMonth
            self.noGrazeOutSelected = true
        }


        if let details = json["details"].string {
            self.details = details
        }
    }

    // MARK: Setters
    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteId = id
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        if self.details.isEmpty || self.action.isEmpty {
            return false
        } else {
            return true
        }
    }

    // MARK: Export
    func toDictionary() -> [String : Any] {
        var actionTypeId = 0
        if let actionTypeObj = Reference.shared.getPlantCommunityActionType(named: action) {
            actionTypeId = actionTypeObj.id
        }

        var noInDay = 0
        var noInMonth = 0
        var noEndDay = 0
        var noEndMonth = 0

        if noGrazeInSelected {
            noInDay = noGrazeInDay
            noInMonth = noGrazeInMonth
        }

        if noGrazeOutSelected {
            noEndDay = noGrazeOutDay
            noEndMonth = noGrazeOutMonth
        }

        return [
            "actionTypeId": actionTypeId,
            "name": action,
            "details": details,
            "noGrazeStartDay": noInDay,
            "noGrazeStartMonth": noInMonth,
            "noGrazeEndDay": noEndDay,
            "noGrazeEndMonth": noEndMonth
        ]
    }

    func copy() -> PastureAction {
        let new = PastureAction()
        new.remoteId = self.remoteId
        new.details = self.details
        new.action = self.action
        new.noGrazeOutSelected = self.noGrazeOutSelected
        new.noGrazeInDay = self.noGrazeInDay
        new.noGrazeInMonth = self.noGrazeInMonth
        new.noGrazeInSelected = self.noGrazeInSelected
        new.noGrazeOutDay = self.noGrazeOutDay
        new.noGrazeOutMonth = self.noGrazeOutMonth
        return new
    }
}
