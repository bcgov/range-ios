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
    @objc dynamic var purposeOfAction: String = "none"

    @objc dynamic var readinessDay: Int = -1
    @objc dynamic var readinessMonth: Int = -1

    var rangeReadiness = List<IndicatorPlant>()
    var stubbleHeight = List<IndicatorPlant>()
    var shrubUse = List<IndicatorPlant>()

    // TODO: Delete
    @objc dynamic var isPurposeOfActionEstablish: Bool = false

    var monitoringAreas = List<MonitoringArea>()
    var pastureActions = List<PastureAction>()

    func requiredFieldsAreFilled() -> Bool {
        if self.name.isEmpty || self.aspect.isEmpty || self.elevation.isEmpty || self.description.isEmpty {
            return false
        } else {
            return true
        }
    }

    func clearPurposeOfAction() {
        do {
            let realm = try Realm()
            try realm.write {
                self.purposeOfAction = "none"
            }
        } catch _ {
            fatalError()
        }
        for action in self.pastureActions {
            RealmRequests.deleteObject(action)
        }
    }

    func addIndicatorPlant(type: IndicatorPlantSection) {
        do {
            let realm = try Realm()
            try realm.write {
                switch type {
                case .RangeReadiness:
                    rangeReadiness.append(IndicatorPlant())
                case .StubbleHeight:
                    stubbleHeight.append(IndicatorPlant())
                case .ShrubUse:
                    shrubUse.append(IndicatorPlant())
                }
            }
        } catch _ {
            fatalError()
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

        for object in self.rangeReadiness {
            new.rangeReadiness.append(object.copy())
        }

        for object in self.stubbleHeight {
            new.stubbleHeight.append(object.copy())
        }

        for object in self.shrubUse {
            new.shrubUse.append(object.copy())
        }

        return new
    }
    
    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }
}
