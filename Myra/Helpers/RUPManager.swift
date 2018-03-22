//
//  RUPManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RUPManager {
    static let shared = RUPManager()
    private init() {}

    func rupHasScheduleForYear(rup: RUP, year: Int) -> Bool {
        let schedules = rup.schedules
        for schedule in schedules {
            if schedule.year == year {
                return true
            }
        }
        return false
    }

    func getPastureNames(rup: RUP) -> [String] {
        var names = [String]()
        for pasture in rup.pastures {
            names.append(pasture.name)
        }
        return names
    }

    func getPasturesLookup(rup: RUP) -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let names = getPastureNames(rup: rup)
        for name in names {
            returnArray.append(SelectionPopUpObject(display: name, value: name))
        }
        return returnArray
    }

    func getPastureNamed(name: String, rup: RUP) -> Pasture? {
        for pasture in rup.pastures {
            if pasture.name == name {
                return pasture
            }
        }
        return nil
    }

    func getScheduleYears(rup: RUP) -> [String] {
        let schedules = rup.schedules
        var years = [String]()
        for schedule in schedules {
            years.append("\(schedule.year)")
        }
        return years
    }

}

// rup / agreement
extension RUPManager {

    func getRUP(with agreementId: String) -> RUP? {
        if rupExists(agreementId: agreementId) {
            let storedRups = RealmRequests.getObject(RUP.self)
            for stored in storedRups! {
                if stored.agreementId == agreementId {
                    return stored
                }
            }
        }
        return nil
    }

    func rupExists(agreementId: String) -> Bool {
        let storedRups = RealmRequests.getObject(RUP.self)
        if storedRups != nil {
            for storedRUP in storedRups! {
                if storedRUP.agreementId == agreementId {
                    return true
                }
            }
        }
        return false
    }

    // will fetch the store rup with the same id,
    // so only pass in the newly downloaded agreement
    func updateRUP(with newAgreement: RUP) {
        let storedRUP = getRUP(with: newAgreement.agreementId)
        if storedRUP == nil {return}

        do {
            let realm = try Realm()
            try realm.write {
//                storedRUP?.status = newAgreement.status
                if newAgreement.zone != nil {
                    storedRUP?.zone = newAgreement.zone
                }
            }

        } catch _ {
            fatalError()
        }
        RealmRequests.updateObject(storedRUP!)
    }

    func diffAgreements(rups: [RUP]) {
        for rup in rups {
            if rupExists(agreementId: rup.agreementId) {
                updateRUP(with: rup)
            } else {
                rup.statusEnum = .Agreement
                RealmRequests.saveObject(object: rup)
            }
        }
    }

    func getAgreements() -> [RUP] {
        let rups = RealmRequests.getObject(RUP.self)
        var agreements = [RUP]()
        if rups == nil {return agreements}
        for rup in (rups)! {
            if rup.statusEnum == .Agreement {
                agreements.append(rup)
            }
        }
        return agreements
    }

    // returns all rups that are not in agreement state
    func getRUPs() -> [RUP] {
        let rups = RealmRequests.getObject(RUP.self)
        var  returnRups = [RUP]()
        if rups == nil {return returnRups}
        for rup in (rups)! {
            if rup.statusEnum != .Agreement {
                 returnRups.append(rup)
            }
        }
        return returnRups
    }
}

// Schedule
extension RUPManager {
    /*
       Sets a schedule object's related pasture object.
       used in lookupPastures in ScheduleObjectTableViewCell and
       should be re used in the future if a rup is downloaded.
       the calculations in the other functions in this extention
       rely on schedule objects being able to reference their assigned pastures.
    */
    func setPastureOn(scheduleObject: ScheduleObject, pastureName: String, rup: RUP) {
        do {
            let realm = try Realm()
            try realm.write {
                scheduleObject.pasture = getPastureNamed(name: pastureName, rup: rup)
            }
        } catch _ {
            fatalError()
        }
        calculate(scheduleObject: scheduleObject)
    }

    func calculate(scheduleObject: ScheduleObject) {
        calculateTotalAUMsFor(scheduleObject: scheduleObject)
        calculatePLDFor(scheduleObject: scheduleObject)
    }

    func calculateTotalAUMsFor(scheduleObject: ScheduleObject) {
        var auFactor = 0.0
        // if animal type hasn't been selected, return 0
        if let animalType = scheduleObject.type {
            auFactor = animalType.auFactor
        } else {
            do {
                let realm = try Realm()
                try realm.write {
                    scheduleObject.totalAUMs = 0.0
                }
            } catch _ {
                fatalError()
            }
            return
        }
        // otherwise continue...

        let numberOfAnimals = Double(scheduleObject.numberOfAnimals)
        let totalDays = Double(scheduleObject.totalDays)

        // Total AUMs = (# of Animals *Days*Animal Class Proportion)/ 30.44
        do {
            let realm = try Realm()
            try realm.write {
                scheduleObject.totalAUMs = (numberOfAnimals * totalDays * auFactor) / 30.44
            }
        } catch _ {
            fatalError()
        }
    }

    func calculatePLDFor(scheduleObject: ScheduleObject) {
        var pasturePLD = 0.0
        // if the schedule object doesn't have a pasture set, return 0
        if let pasture = scheduleObject.pasture {
            pasturePLD = pasture.privateLandDeduction
        } else {
            do {
                let realm = try Realm()
                try realm.write {
                   scheduleObject.pldAUMs = 0.0
                }
            } catch _ {
                fatalError()
            }
            return
        }
        // otherwise continue...

        // Private Land Deduction = Total AUMs * % PLD entered for that pasture
        do {
            let realm = try Realm()
            try realm.write {
                scheduleObject.pldAUMs = (scheduleObject.totalAUMs * (pasturePLD / 100))
            }
        } catch _ {
            fatalError()
        }
    }

    func getTotalAUMsFor(schedule: Schedule) -> Double{
        var total = 0.0
        for object in schedule.scheduleObjects {
            total = total + object.totalAUMs
        }
        return total
    }

    // if livestock with the specified name is not found, returns false
    func setLiveStockTypeFor(scheduleObject: ScheduleObject, liveStock: String) -> Bool {
        let ls = RealmManager.shared.getLiveStockTypeObject(name: liveStock)
        // if found
        if ls.0 {
            do {
                let realm = try Realm()
                try realm.write {
                    scheduleObject.type = ls.1
                }
            } catch _ {
                fatalError()
            }
            return true
        } else {
            return false
        }
    }
}
