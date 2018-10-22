//
//  InvasivePlant.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class InvasivePlants: Object {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var other: String = ""
    @objc dynamic var equipmentAndVehiclesParking: Bool = false
    @objc dynamic var beginInUninfestedArea: Bool = false
    @objc dynamic var undercarrigesInspected: Bool = false
    @objc dynamic var revegetate: Bool = false

    func requiredFieldsAreFilled() -> Bool {
        if !equipmentAndVehiclesParking || !beginInUninfestedArea || !undercarrigesInspected || !revegetate {
            return false
        } else {
            return true
        }
    }

    func setValue(other: String? = nil, equipmentAndVehiclesParking: Bool? = nil, beginInUninfestedArea: Bool? = nil, undercarrigesInspected: Bool? = nil, revegetate: Bool? = nil) {
        do {
            let realm = try Realm()
            try realm.write {
                if let otherOption = other {
                    self.other = otherOption
                }
                if let equpmentParking = equipmentAndVehiclesParking {
                    self.equipmentAndVehiclesParking = equpmentParking
                }
                if let uninfestedArea = beginInUninfestedArea {
                    self.beginInUninfestedArea = uninfestedArea
                }
                if let inspected = undercarrigesInspected {
                    self.undercarrigesInspected = inspected
                }
                if let revegetation = revegetate {
                    self.revegetate = revegetation
                }
            }
        } catch {
            fatalError()
        }
    }

    func clone() -> InvasivePlants {
        let invasivePlants = InvasivePlants()
        invasivePlants.other = self.other
        invasivePlants.equipmentAndVehiclesParking = self.equipmentAndVehiclesParking
        invasivePlants.beginInUninfestedArea = self.beginInUninfestedArea
        invasivePlants.undercarrigesInspected = self.undercarrigesInspected
        invasivePlants.revegetate = self.revegetate
        return invasivePlants
    }

    func toDictionary() -> [String : Any] {
        return [String:Any]()
    }
    
}
