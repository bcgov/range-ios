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

    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }


    @objc dynamic var actionTypeID: Int = -1
    @objc dynamic var actionType: String = ""
    @objc dynamic var desc: String = ""

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

    func toDictionary() -> [String:Any] {
        return [
            "detail": self.desc,
            "actionTypeId": self.actionTypeID,
        ]
    }

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
    }

    func copy() -> MinisterIssueAction {
        let new = MinisterIssueAction()
        new.remoteId = self.remoteId
        new.actionType = self.actionType
        new.actionTypeID = self.actionTypeID
        new.desc = self.desc
        return new
    }
}
