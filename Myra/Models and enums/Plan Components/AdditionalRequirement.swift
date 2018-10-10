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

    func copy() -> AdditionalRequirement {
        let new = AdditionalRequirement()
        new.category = self.category
        new.url = self.url
        new.detail = self.detail
        return new
    }

    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }

}
