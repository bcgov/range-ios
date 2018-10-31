//
//  AdditionalRequirement.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class AdditionalRequirement: Object {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var category: String = ""
    @objc dynamic var detail: String = ""
    @objc dynamic var url: String = ""

    func requiredFieldsAreFilled() -> Bool {
        if category.isEmpty || detail.isEmpty {
            return false
        } else {
            return true
        }
    }


    func setValue(category: String? = nil, detail: String? = nil, url: String? = nil) {
        do {
            let realm = try Realm()
            try realm.write {
                if let cat = category {
                    self.category = cat
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

    func clone() -> AdditionalRequirement {
        let new = AdditionalRequirement()
        new.category = self.category
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
        if let categoryJSON = json["category"].dictionaryObject, let categoryName = categoryJSON["name"] as? String {
            self.category = categoryName
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
        if let considerationType = Reference.shared.getAdditionalRequirementCategory(named: category) {
            typeId = considerationType.id
        }
        return [
            "categoryId":typeId,
            "url": self.url,
            "detail": self.detail
        ]
    }
}
