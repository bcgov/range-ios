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
import SwiftyJSON

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
    @objc dynamic var purposeOfAction: String = "Clear"

    @objc dynamic var readinessDay: Int = -1
    @objc dynamic var readinessMonth: Int = -1
    @objc dynamic var readinessNotes: String = ""

    var rangeReadiness = List<IndicatorPlant>()
    var stubbleHeight = List<IndicatorPlant>()
    var shrubUse = List<IndicatorPlant>()

    @objc dynamic var approvedByMinister: Bool = false

    var monitoringAreas = List<MonitoringArea>()
    var pastureActions = List<PastureAction>()

    func requiredFieldsAreFilled() -> Bool {
        if self.name.isEmpty || self.elevation.isEmpty || self.description.isEmpty {
            return false
        } else {
            return true
        }
    }

    func clearPurposeOfAction() {
        do {
            let realm = try Realm()
            try realm.write {
                self.purposeOfAction = "Clear"
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
                    rangeReadiness.append(IndicatorPlant(criteria: "\(type)"))
                case .StubbleHeight:
                    stubbleHeight.append(IndicatorPlant(criteria: "\(type)"))
                case .ShrubUse:
                    shrubUse.append(IndicatorPlant(criteria: "\(type)"))
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
        new.approvedByMinister = self.approvedByMinister

        new.readinessDay = self.readinessDay
        new.readinessMonth = self.readinessMonth
        new.readinessNotes = self.readinessNotes

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

        if let name = json["name"].string {
            self.name = name
        }

        if let notes = json["notes"].string {
            self.notes = notes
        }

        if let aspect = json["aspect"].string {
            self.aspect = aspect
        }

        if let url = json["url"].string {
            self.communityURL = url
        }

        if let approved = json["approved"].bool{
            self.approvedByMinister = approved
        }

        if let rangeReadinessMonth = json["rangeReadinessMonth"].int {
            self.readinessMonth = rangeReadinessMonth
        }

        if let rangeReadinessDay = json["rangeReadinessDay"].int {
            self.readinessDay = rangeReadinessDay
        }

        if let purposeAction = json["purposeOfAction"].string {
            if purposeAction.lowercased().contains("establish") {
                self.purposeOfAction = "Establish Plant Community"
            } else if purposeAction.lowercased().contains("maintain") {
                self.purposeOfAction = "Maintain Plant Community"
            } else {
                self.purposeOfAction = "Clear"
            }
        }

        if let elevationJSON = json["elevation"].dictionaryObject, let elevationName = elevationJSON["name"] as? String {
            elevation = elevationName
        }

        let indicatorPlants = json["indicatorPlants"]
        for indicatorPlant in indicatorPlants {
            if let criteria = indicatorPlant.1["criteria"].string {
                if criteria.lowercased() == "rangereadiness" {
                    self.rangeReadiness.append(IndicatorPlant(json: indicatorPlant.1))
                } else if criteria.lowercased() == "stubbleheight" {
                    self.stubbleHeight.append(IndicatorPlant(json: indicatorPlant.1))
                } else if criteria.lowercased() == "shrubuse" {
                    self.shrubUse.append(IndicatorPlant(json: indicatorPlant.1))
                }
            }
        }

        let plantCommunityActions = json["plantCommunityActions"]
        for action in plantCommunityActions {
            pastureActions.append(PastureAction(json: action.1))
        }

        let monitoringAreasJSON = json["monitoringAreas"]
        for element in monitoringAreasJSON {
            self.monitoringAreas.append(MonitoringArea(json: element.1))
        }
    }
    
    func toDictionary() -> [String : Any] {
        var typeId = 0
        var elevationId = 0
        if let elevationObj = Reference.shared.getPlantCommunityElevation(named: elevation) {
            elevationId = elevationObj.id
        }

        if let type = Reference.shared.getPlantCommunitType(named: self.name) {
            typeId = type.id
        }

        var readyDay: Int = readinessDay
        var readyMonth: Int = readinessMonth

        if readyDay == -1 {
            readyDay = 0
        }
        if readyMonth == -1 {
            readyMonth = 0
        }

        var purpose = "none"

        if purposeOfAction.lowercased().contains("establish") {
            purpose = "establish"
        } else if purposeOfAction.lowercased().contains("maintain") {
            purpose = "maintain"
        }

        return [
            "name": name,
            "communityTypeId": typeId,
            "elevationId": elevationId,
            "purposeOfAction": purpose,
            "aspect": aspect,
            "url": communityURL,
            "notes": notes,
            "rangeReadinessDay": readyDay,
            "rangeReadinessMonth": readyMonth,
            "rangeReadinessNote": readinessNotes,
            "approved": approvedByMinister
        ]
    }

    func getIndicatorPlants() -> [IndicatorPlant] {
        var indicatorPlants: [IndicatorPlant] = [IndicatorPlant]()
        indicatorPlants.append(contentsOf: rangeReadiness)
        indicatorPlants.append(contentsOf: stubbleHeight)
        indicatorPlants.append(contentsOf: shrubUse)
        return indicatorPlants
    }

    func importRangeReadiness(from pc: PlantCommunity) {
        for element in self.rangeReadiness {
            RealmRequests.deleteObject(element)
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.readinessDay = pc.readinessDay
                self.readinessMonth = pc.readinessMonth
                self.readinessNotes = pc.readinessNotes
                for indicatorPlant in pc.rangeReadiness {
                    self.rangeReadiness.append(indicatorPlant)
                }
            }
        } catch _ {
            fatalError()
        }
    }

    func importStubbleHeight(from pc: PlantCommunity) {
        for element in self.stubbleHeight {
            RealmRequests.deleteObject(element)
        }
        do {
            let realm = try Realm()
            try realm.write {
                for indicatorPlant in pc.stubbleHeight {
                    self.stubbleHeight.append(indicatorPlant)
                }
            }
        } catch _ {
            fatalError()
        }
    }

    func importShrubUse(from pc: PlantCommunity) {
        for element in self.shrubUse {
            RealmRequests.deleteObject(element)
        }
        do {
            let realm = try Realm()
            try realm.write {
                for indicatorPlant in pc.shrubUse {
                    self.shrubUse.append(indicatorPlant)
                }
            }
        } catch _ {
            fatalError()
        }
    }
}
