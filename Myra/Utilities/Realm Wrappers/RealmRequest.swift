//
//  RealmRequest.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct RealmRequests {
//    static func getKey() -> Data {
//        let key = "W3VCPVGTL32XXSWHXXVVF4EYCLRYR399DFRPQSVRPT99J0A31UC2WBCGRKMI6I1X"
//        let data = key.data(using: .ascii)!
//        return data
//    }
//
//    static func getEncryptConfig() -> Realm.Configuration {
//        return Realm.Configuration()
//    }

    static func saveObject<T: Object>(object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    static func updateObject<T: Object>(_ object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: true)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    static func deleteObject<T: Object>(_ object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(object)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseDeleteFailure)
        }
    }

    static func getObject<T: Object>(_ object: T.Type) -> [T]? {
        do {
            let realm = try Realm()
            let objs = realm.objects(object).map { $0 }
            return Array(objs)
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
        return nil
    }
}
