//
//  PlantCommunity.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PlantCommunity: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var aspect: String = ""
    @objc dynamic var elevation: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var communityURL: String = ""
    @objc dynamic var purposeOfAction: String = ""

    // TODO: Delete
    @objc dynamic var isPurposeOfActionEstablish: Bool = false

    var monitoringAreas = List<MonitoringArea>()
    var pastureActions = List<PastureAction>()

    func clearPurposeOfAction() {
        do {
            let realm = try Realm()
            try realm.write {
                self.purposeOfAction = ""
            }
        } catch _ {
            fatalError()
        }
        for action in self.pastureActions {
            RealmRequests.deleteObject(action)
        }
    }

    func copy() -> PlantCommunity {
        let new = PlantCommunity()
        new.name = self.name
        new.aspect = self.aspect
        new.elevation = self.elevation
        new.notes = self.notes
        new.communityURL = self.communityURL
        new.purposeOfAction = self.purposeOfAction

        for object in self.monitoringAreas {
            new.monitoringAreas.append(object.copy())
        }

        for object in self.pastureActions {
            new.pastureActions.append(object.copy())
        }

        return new
    }
    
    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }
}
