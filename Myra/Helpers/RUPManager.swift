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

    func getType(id: Int) -> String {
        let types = RealmRequests.getObject(AgreementType.self)
        if types != nil {
            for type in types! {
                if type.id == id {
                    return type.desc
                }
            }
        }
        return ""
    }

 }

 // rup / agreement
 extension RUPManager {

    func getRUP(with id: String) -> RUP? {
        if rupExists(id: id) {
            let storedRups = RealmRequests.getObject(RUP.self)
            for stored in storedRups! {
                if stored.id == id {
                    return stored
                }
            }
        }
        return nil
    }

    func rupExists(id: String) -> Bool {
        let storedRups = RealmRequests.getObject(RUP.self)
        if storedRups != nil {
            for storedRUP in storedRups! {
                if storedRUP.id == id {
                    return true
                }
            }
        }
        return false
    }

    // will fetch the store rup with the same id,
    // so only pass in the newly downloaded agreement
    // TODO: Refactor - schema change
    func updateRUP(with newRUP: RUP) {
        let storedRUP = getRUP(with: newRUP.agreementId)
        if storedRUP == nil {return}

        do {
            let realm = try Realm()
            try realm.write {
                if newRUP.zones.count > 0 {
                    storedRUP?.zones = newRUP.zones
                }
            }

        } catch _ {
            fatalError()
        }
        RealmRequests.updateObject(storedRUP!)
    }

    // TODO: Refactor - schema change
    func diffRup(rups: [RUP]) {
        for rup in rups {
            if rupExists(id: rup.id) {
                updateRUP(with: rup)
            } else {
                rup.statusEnum = .Agreement
                RealmRequests.saveObject(object: rup)
            }
        }
    }

    func getAgreement(with id: String) -> Agreement? {
        if agreementExists(id: id) {
            let storedAgreements = RealmRequests.getObject(Agreement.self)
            if storedAgreements != nil {
                for storedAgreement in storedAgreements! {
                    if storedAgreement.agreementId == id {
                        return storedAgreement
                    }
                }
            }
        }
        return nil
    }

    func agreementExists(id: String) -> Bool {
        let storedAgreements = RealmRequests.getObject(Agreement.self)
        if storedAgreements != nil {
            for storedAgreement in storedAgreements! {
                if storedAgreement.agreementId == id {
                    return true
                }
            }
        }
        return false
    }

    // Updates Range use years and zones
    func updateAgreement(with newAgreement: Agreement) {
        let storedAgreement = getAgreement(with: newAgreement.agreementId)
        if storedAgreement == nil {return}

        do {
            let realm = try Realm()
            try realm.write {
                storedAgreement?.zones = newAgreement.zones
                storedAgreement?.rangeUsageYears = newAgreement.rangeUsageYears
                if newAgreement.zones.count > 0 {
                    storedAgreement?.zones = newAgreement.zones
                    storedAgreement?.rangeUsageYears = newAgreement.rangeUsageYears
                }
            }

        } catch _ {
            fatalError()
        }
        RealmRequests.updateObject(storedAgreement!)
    }

    func diffAgreements(agreements: [Agreement]) {
        for agreement in agreements {
            if agreementExists(id: agreement.agreementId) {
                updateAgreement(with: agreement)
            } else {
                RealmRequests.saveObject(object: agreement)
            }
        }
    }

    func getAgreements() -> [Agreement] {
        let agreementObjects = RealmRequests.getObject(Agreement.self)
        if let agreements: [Agreement] = agreementObjects {
            return agreements
        } else {
            return [Agreement]()
        }
    }

    func getAgreementsWithNoRUPs() -> [Agreement] {
        let agreements = getAgreements()
        var filtered = [Agreement]()
        for agreement in agreements {
            if agreement.rups.count < 1 {
                filtered.append(agreement)
            }
        }
        return filtered
    }

    // TODO
    /*
    func getRUPsForAgreement() -> [RUP] {
        let rups = RealmRequests.getObject(RUP.self)
        var agreements = [RUP]()
//        if rups == nil {return agreements}
//        for rup in (rups)! {
//            if rup.statusEnum == .Agreement {
//                agreements.append(rup)
//            }
//        }
        return agreements
    }
     */

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

    func genRUP(forAgreement: Agreement) -> RUP {
        let rup = RUP()
        rup.setFrom(agreement: forAgreement)
        do {
            let realm = try Realm()
            try realm.write {
                forAgreement.rups.append(rup)
            }
        } catch _ {
            fatalError()
        }
        RealmRequests.saveObject(object: rup)
        return rup
    }

    func getUsageFor(year: Int, agreementId: String) -> RangeUsageYear? {
        let usages = RealmRequests.getObject(RangeUsageYear.self)

        if usages == nil {return nil}
        for usage in usages! {

            if usage.agreementId == agreementId && usage.year == year {
                return usage
            }
        }
        return nil
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
            total = total + object.crownAUMs
        }
        return total
    }

    func isScheduleValid(schedule: Schedule, agreementID: String) -> Bool {
        let totAUMs = getTotalAUMsFor(schedule: schedule)
        let usage = getUsageFor(year: schedule.year, agreementId: agreementID)
        let allowed = usage?.auth_AUMs ?? 0

        print(totAUMs)
        print(usage ?? "nil")
        print(allowed)
        return totAUMs <= Double(allowed)

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

    func getPasturesArray(rup: RUP) -> [Pasture] {
        let ps = rup.pastures
        var returnVal = [Pasture]()
        for p in ps {
            returnVal.append(p)
        }
        return returnVal
    }

    func getSchedulesArray(rup: RUP) -> [Schedule] {
        let ss = rup.schedules
        var returnVal = [Schedule]()
        for s in ss {
            returnVal.append(s)
        }
        return returnVal
    }

    func getNextScheduleYearFor(from: Int, rup: RUP) -> Int {
        let taken = getScheduleYears(rup: rup)
        var new = from
        while taken.contains("\(new)") {
            new = new + 1
        }
        return new
    }

    func sortSchedule(rup: RUP) {
        let sorted = rup.schedules.sorted(by: { $0.year < $1.year })
        let list: List<Schedule> = List<Schedule>()
        for element in sorted {
            list.append(element)
        }

        do {
            let realm = try Realm()
            try realm.write {
                rup.schedules = list
            }
        } catch _ {
            fatalError()
        }
    }

    func updateSchedulesForPasture(pasture: Pasture, in rup: RUP) {
        let query = RealmRequests.getObject(ScheduleObject.self)
        if let scheduleObjects = query {
            for object in scheduleObjects {
                if object.pasture?.realmID == pasture.realmID {
                    print(object)
                    calculate(scheduleObject: object)
                    print(object)
                    print("done")
                }
            }
        }
    }

    func getAgreementExemptionStatusFor(id: Int) -> AgreementExemptionStatus {
        let query = RealmRequests.getObject(AgreementExemptionStatus.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return AgreementExemptionStatus()
    }

    func getLiveStockIdentifierTypeFor(id: Int) -> LivestockIdentifierType {
        let query = RealmRequests.getObject(LivestockIdentifierType.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return LivestockIdentifierType()
    }

    func getPlanStatusFor(id: Int) -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return PlanStatus()
    }

    func getClientTypeFor(id: Int) -> ClientType {
        let query = RealmRequests.getObject(ClientType.self)
        if let all = query {
            for object in all {
                if object.id == id {
                    return object
                }
            }
        }
        return ClientType()
    }

    func clearStoredReferenceData() {
        let query1 = RealmRequests.getObject(ClientType.self)
        let query2 = RealmRequests.getObject(PlanStatus.self)
        let query3 = RealmRequests.getObject(LivestockIdentifierType.self)
        let query4 = RealmRequests.getObject(AgreementExemptionStatus.self)
        let query5 = RealmRequests.getObject(AgreementStatus.self)
        let query6 = RealmRequests.getObject(LiveStockType.self)
        let query7 = RealmRequests.getObject(AgreementType.self)

        removeAllObjectsIn(query: query1)
        removeAllObjectsIn(query: query2)
        removeAllObjectsIn(query: query3)
        removeAllObjectsIn(query: query4)
        removeAllObjectsIn(query: query5)
        removeAllObjectsIn(query: query6)
        removeAllObjectsIn(query: query7)
    }

    func clearStoredReferenceData2() {
        var objects = [Object]()

        if let query1: [Object] = RealmRequests.getObject(ClientType.self) {
            objects.append(contentsOf: query1)
        }
        if let query2: [Object] = RealmRequests.getObject(PlanStatus.self) {
            objects.append(contentsOf: query2)
        }
        if let query3: [Object] = RealmRequests.getObject(LivestockIdentifierType.self) {
            objects.append(contentsOf: query3)
        }
        if let query4: [Object] = RealmRequests.getObject(AgreementExemptionStatus.self) {
            objects.append(contentsOf: query4)
        }
        if let query5: [Object] = RealmRequests.getObject(AgreementStatus.self) {
            objects.append(contentsOf: query5)
        }
        if let query6: [Object] = RealmRequests.getObject(LiveStockType.self) {
            objects.append(contentsOf: query6)
        }
        if let query7: [Object] = RealmRequests.getObject(AgreementType.self) {
            objects.append(contentsOf: query7)
        }

        removeAllObjectsIn(query: objects)
    }

    func removeAllObjectsIn(query: [Object]?) {
        if query == nil {return}
        for object in query! {
            RealmRequests.deleteObject(object)
        }
    }

    func storeNewReferenceData(objects: [Object]) {
        for object in objects {
            RealmRequests.saveObject(object: object)
        }
    }

    func updateReferenceData(objects: [Object]) {
        clearStoredReferenceData()
        storeNewReferenceData(objects: objects)
    }
 }