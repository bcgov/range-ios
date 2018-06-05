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
}
