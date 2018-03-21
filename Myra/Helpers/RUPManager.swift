//
//  RUPManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

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


// Schedule section

extension RUPManager {
    /*
       Sets a schedule object's related pasture object.
       used in lookupPastures in ScheduleObjectTableViewCell and
       should be re used in the future if a rup is downloaded.
       the calculations in the other functions in this extention
       rely on schedule objects being able to reference their assigned pastures.
    */
    func setPastureOn(scheduleObject: ScheduleObject, pastureName: String, rup: RUP) {
        scheduleObject.pasture = getPastureNamed(name: pastureName, rup: rup)
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
            scheduleObject.totalAUMs = 0.0
            return
        }
        // otherwise continue...

        let numberOfAnimals = Double(scheduleObject.numberOfAnimals)
        let totalDays = Double(scheduleObject.totalDays)

        // Total AUMs = (# of Animals *Days*Animal Class Proportion)/ 30.44
        scheduleObject.totalAUMs = (numberOfAnimals * totalDays * auFactor) / 30.44
    }

    func calculatePLDFor(scheduleObject: ScheduleObject) {
        var pasturePLD = 0.0
        // if the schedule object doesn't have a pasture set, return 0
        if let pasture = scheduleObject.pasture {
            pasturePLD = pasture.privateLandDeduction
        } else {
            scheduleObject.pldAUMs = 0.0
            return
        }
        // otherwise continue...

        // Private Land Deduction = Total AUMs * % PLD entered for that pasture
        scheduleObject.pldAUMs = (scheduleObject.totalAUMs * (pasturePLD / 100))
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
            scheduleObject.type = ls.1
            return true
        } else {
            return false
        }
    }
}
