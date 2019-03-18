//
//  MinisterIssueAction.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class MinisterIssueAction: Object, MyraObject {

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var actionTypeID: Int = -1
    @objc dynamic var actionType: String = ""
    @objc dynamic var otherActionTypeName: String = ""
    @objc dynamic var desc: String = ""
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

        if let detail = json["detail"].string {
            self.desc = detail
        }

        if let typeName = json["ministerIssueActionType"]["name"].string {
            self.actionType = typeName
        }

        if let actionTypeId = json["actionTypeId"].int {
            self.actionTypeID = actionTypeId
        }
        
        if let otherActionTypeName = json["other"].string {
            self.otherActionTypeName = otherActionTypeName
        }
        
        if let inDay = json["noGrazeStartDay"].int, let inMonth = json["noGrazeStartMonth"].int {
            self.noGrazeInDay = inDay
            self.noGrazeInMonth = inMonth
            self.noGrazeInSelected = true
        }
        
        if let outDay = json["noGrazeEndDay"].int, let outMonth = json["noGrazeEndMonth"].int {
            self.noGrazeOutDay = outDay
            self.noGrazeOutMonth = outMonth
            self.noGrazeOutSelected = true
        }
    }

    // MARK: Setters
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
        if self.actionType.lowercased() == "timing" && (!noGrazeInSelected || !noGrazeInSelected) {
            return false
        }

        return !(self.actionTypeID == -1 || self.desc.isEmpty)
    }

    // MARK: Export
    func copy() -> MinisterIssueAction {
        let new = MinisterIssueAction()
        new.remoteId = self.remoteId
        new.actionType = self.actionType
        new.actionTypeID = self.actionTypeID
        new.otherActionTypeName = self.otherActionTypeName
        new.desc = self.desc
        new.noGrazeOutSelected = self.noGrazeOutSelected
        new.noGrazeInDay = self.noGrazeInDay
        new.noGrazeInMonth = self.noGrazeInMonth
        new.noGrazeInSelected = self.noGrazeInSelected
        new.noGrazeOutDay = self.noGrazeOutDay
        new.noGrazeOutMonth = self.noGrazeOutMonth
        return new
    }

    func toDictionary() -> [String:Any] {
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
            "detail": self.desc,
            "actionTypeId": self.actionTypeID,
            "other": self.otherActionTypeName,
            "noGrazeEndDay": noEndDay ,
            "noGrazeEndMonth": noEndMonth,
            "noGrazeStartDay": noInDay,
            "noGrazeStartMonth": noInMonth,
        ]
    }
}
