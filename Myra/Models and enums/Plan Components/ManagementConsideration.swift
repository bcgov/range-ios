//
//  ManagementConsideration.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class ManagementConsideration: Object {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var consideration: String = ""
    @objc dynamic var detail: String = ""
    @objc dynamic var url: String = ""

    func setValue(consideration: String? = nil, detail: String? = nil, url: String? = nil) {
        do {
            let realm = try Realm()
            try realm.write {
                if let cansider = consideration {
                    self.consideration = cansider
                }
                if let det = detail {
                    self.detail = det
                }
                if let link = url {
                    self.url = link
                }
            }
        } catch {
            fatalError()
        }
    }

    func clone() -> ManagementConsideration {
        let new = ManagementConsideration()
        new.consideration = self.consideration
        new.url = self.url
        new.detail = self.detail
        return new
    }

    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteId = id
            }
        } catch _ {
            fatalError()
        }
    }

    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let considerationTypeJSON = json["considerationType"].dictionaryObject, let considerationTypeName = considerationTypeJSON["name"] as? String {
            self.consideration = considerationTypeName
        }

        if let detailValue = json["detail"].string {
            self.detail = detailValue
        }

        if let urlValue = json["url"].string {
            self.url = urlValue
        }
    }

    func toDictionary() -> [String : Any] {
        var typeId = 0
        if let considerationType = Reference.shared.getManagementConsideration(named: consideration) {
            typeId = considerationType.id
        }
        return [
            "considerationTypeId":typeId,
            "url": self.url,
            "detail": self.detail
        ]
    }

}
