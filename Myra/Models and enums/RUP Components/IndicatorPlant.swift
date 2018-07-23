//
//  IndicatorPlant.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class IndicatorPlant: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var type: String = ""
    @objc dynamic var number: Double = 0
    @objc dynamic var freeText: String = ""

    func getDetail() -> String {
        if type.lowercased() == "other" {
            return freeText
        } else {
            return "\(number)"
        }
    }

    func setDetail(text: String) {
        if type.lowercased() == "other" {
            do {
                let realm = try Realm()
                try realm.write {
                    freeText = text
                }
            } catch _ {
                fatalError()
            }
        } else if text.isDouble {
            do {
                let realm = try Realm()
                try realm.write {
                    number = Double(text)!
                }
            } catch _ {
                fatalError()
            }
        }
    }

    func copy() -> IndicatorPlant {
        let new = IndicatorPlant()
        new.number = self.number
        new.freeText = self.freeText
        new.type = self.type
        return new
    }
}
