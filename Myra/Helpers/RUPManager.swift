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
 
 // MARK: RUP / Agreement
 extension RUPManager {
    func cleanPlans() {
        let plans = self.getRUPs()
        for plan in plans where plan.isNew {
            RealmRequests.deleteObject(plan)
        }
    }
    
    func isValid(rup: RUP) -> (Bool, String) {
        // check required fields
        if !rup.isValid {return (false, "Missing required fields")}
        
        // check validity of schedules
        for element in rup.schedules {
            if !isScheduleValid(schedule: element, agreementID: rup.agreementId) {
                return (false, "Plan has an invalid schedule")
            }
        }
        
        // check that minister's issues have been identified by minister
        for issue in rup.ministerIssues {
            if !issue.identified {
                return(false, "One or more Minister's Issues and Actions has not been identified by minister")
            }
        }
        
        return (true, "")
    }
    
    func getRUP(withId id: Int) -> RUP? {
        if rupExists(id: id) {
            let storedRups = RealmRequests.getObject(RUP.self)
            for stored in storedRups! {
                if stored.remoteId == id {
                    return stored
                }
            }
        }
        return nil
    }
    
    func rupExists(id: Int) -> Bool {
        let storedRups = RealmRequests.getObject(RUP.self)
        if storedRups != nil {
            for storedRUP in storedRups! {
                if storedRUP.remoteId == id {
                    return true
                }
            }
        }
        return false
    }
    
    // will fetch the stored rup with the same id,
    // so only pass in the newly downloaded agreement
    // TODO: Refactor - schema change
    func updateRUP(with newRUP: RUP) {
        let storedRUP = getRUP(withId: newRUP.remoteId)
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
    
    func getAgreement(with id: String) -> Agreement? {
        if let storedAgreements = RealmRequests.getObject(Agreement.self) {
            //            for storeda in storedAgreements where storeda.agreementId == id {
            //                print("\(storeda.agreementId) has \(storeda.rups.count) rup ")
            //            }
            for storedAgreement in storedAgreements where storedAgreement.agreementId == id {
                return storedAgreement
            }
        }
        return nil
    }
    
    func agreementExists(id: String) -> Bool {
        if let _ = getAgreement(with: id) {
            return true
        } else {
            return false
        }
    }
    
    func planExists(remoteId: Int) -> Bool {
        if let _ = getPlanWith(remoteId: remoteId) {return true}
        return false
    }
    
    func getPlanWith(remoteId: Int) -> RUP? {
        guard let plans = RealmRequests.getObject(RUP.self) else {return nil}
        for plan in plans {
            if plan.remoteId == remoteId {
                return plan
            }
        }
        return nil
    }
    
    // Updates Range use years and zones
    func updateAgreement(with newAgreement: Agreement) {
        guard let stored = getAgreement(with: newAgreement.agreementId) else {return}
        
        // Grab zones, range use years
        if newAgreement.zones.count > 0 {
            do {
                let realm = try Realm()
                try realm.write {
                    stored.zones = newAgreement.zones
                    stored.rangeUsageYears = newAgreement.rangeUsageYears
                }
            } catch _ {
                fatalError()
            }
        }
        
        if !newAgreement.rups.isEmpty {
            for plan in newAgreement.rups  {
                do {
                    let realm = try Realm()
                    try realm.write {
                        stored.rups.append(plan)
                    }
                } catch _ {
                    fatalError()
                }
            }
        }
        
        //        if !stored.rups.isEmpty, let plan = stored.rups.first, plan.statusEnum == .LocalDraft {
        //            // if agreement has a plan in local draft state, leave it be
        //
        //            // TODO: CHECK WHICH IS NEWER
        //            if let remote =  newAgreement.rups.first, let remoteDate = remote.remotelyCreatedAt , let localDate = plan.locallyUpdatedAt {
        //                if localDate > remoteDate {
        //                    print("local is newer")
        //                } else {
        //                    print("remote is newer")
        //                }
        //                print("**")
        //            }
        //
        //        } else {
        //            // Otherwise if new agreement has a plan downloaded with it, store it
        //            if !newAgreement.rups.isEmpty, let plan = newAgreement.rups.first {
        //                do {
        //                    let realm = try Realm()
        //                    try realm.write {
        //                        stored.rups.append(plan)
        //                    }
        //                } catch _ {
        //                    fatalError()
        //                }
        //            }
        //        }

        if stored.isInvalidated {
            print("stored is invalidated")
        }

        if newAgreement.isInvalidated {
            print("newAgreement is invalidated")
        }
        
        if !newAgreement.rups.isEmpty {
            let newPlans = newAgreement.rups
            for newPlan in newPlans {
                if newPlan.isInvalidated {
                    print("newPlan is invalidated")
                }
                do {
                    let realm = try Realm()
                    try realm.write {
                        stored.rups.append(newPlan)
                    }
                } catch _ {
                    fatalError()
                }

            }
        }
        
        updateRUPsFor(agreement: stored)
        
        RealmRequests.updateObject(stored)
    }
    
    func updateRUPsFor(agreement: Agreement) {
        for plan in agreement.rups {
            if agreement.zones.count > 0 {
                do {
                    let realm = try Realm()
                    try realm.write {
                        plan.zones.removeAll()
                        for zone in agreement.zones {
                            plan.zones.append(zone)
                        }
                        plan.rangeUsageYears.removeAll()
                        for year in agreement.rangeUsageYears {
                            plan.rangeUsageYears.append(year)
                        }
                    }
                } catch _ {
                    fatalError()
                }
            }
            RealmRequests.updateObject(plan)
        }
    }
    
    func diffAgreements(agreements: [Agreement]) {
        
        // Remove unassigned agreements:
        removeUnassignedAgreements(newAgreements: agreements)
        
        // Update existing agreements:
        for agreement in agreements {
            if agreementExists(id: agreement.agreementId) {
                updateAgreement(with: agreement)
            } else {
                RealmRequests.saveObject(object: agreement)
            }
        }
    }
    
    func removeUnassignedAgreements(newAgreements: [Agreement]) {
        // cache new ids
        var newIds = [String]()
        for agreement in newAgreements {
            newIds.append(agreement.agreementId)
        }
        
        let storedAgreements = getAgreements()
        for agreement in storedAgreements {
            // if stored agreement id was not pulled from server,
            if !newIds.contains(agreement.agreementId) {
                // 1st remove all plans that have this agreement id
                let plans = getRUPsForAgreement(agreementId: agreement.agreementId)
                for plan in plans {
                    RealmRequests.deleteObject(plan)
                }
                // then remove agreement
                RealmRequests.deleteObject(agreement)
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
    
    func getRUPsForAgreement(agreementId: String) -> [RUP] {
        let rups = RealmRequests.getObject(RUP.self)
        var found = [RUP]()
        if let all = rups {
            for rup in all {
                if rup.agreementId == agreementId {
                    found.append(rup)
                }
            }
        }
        return found
    }
    
    func getRUPs() -> [RUP] {
        let rups = RealmRequests.getObject(RUP.self)
        if let all = rups {
            return all
        } else {
            return [RUP]()
        }
    }
    
    func getDraftRups() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'LocalDraft'").map{ $0 }
            return Array(objs)
        } catch _ {}
        return [RUP]()
    }
    
    func getPendingRups() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'Pending'").map{ $0 }
            return Array(objs)
        } catch _ {}
        return [RUP]()
    }
    
    func getCompletedRups() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'Completed'").map{ $0 }
            return Array(objs)
        } catch _ {}
        return [RUP]()
    }
    
    func getOutboxRups() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'Outbox'").map{ $0 }
            return Array(objs)
        } catch _ {}
        return [RUP]()
    }
    
    func getSubmittedPlans() -> [RUP] {
        var plans = getCompletedRups()
        plans.append(contentsOf: getPendingRups())
        return plans
    }
    
    func genRUP(forAgreement: Agreement) -> RUP {
        let rup = RUP()
        rup.setFrom(agreement: forAgreement)
        do {
            let realm = try Realm()
            try realm.write {
                forAgreement.rups.append(rup)
                rup.isNew = true
            }
        } catch _ {
            fatalError()
        }
        RealmRequests.saveObject(object: rup)
        return rup
    }
    
    func getPrimaryAgreementHolderObjectFor(rup: RUP) -> Client {
        for client in rup.clients {
            if client.clientTypeCode == "A" {
                return client
            }
        }
        return Client()
    }
    
    func getPrimaryAgreementHolderFor(rup: RUP) -> String {
        for client in rup.clients {
            if client.clientTypeCode == "A" {
                return client.name
            }
        }
        return ""
    }
    
 }
 
 // MARK: Plant communities
 extension RUPManager {
    func deletePlantCommunity(plantCommunity: PlantCommunity) {
        // remove all monitoring areas and pasture actions
        do {
            let realm = try Realm()
            let refetch = realm.objects(PlantCommunity.self).filter("localId = %@", plantCommunity.localId).first!
            for item in refetch.monitoringAreas {
                deleteMonitoringArea(monitoringArea: item)
            }
            
            for item in refetch.pastureActions {
                deletePastureAction(pastureAction: item)
            }
            
            RealmRequests.deleteObject(refetch)
        } catch _ {
            fatalError()
        }
        //        RealmRequests.deleteObject(refe)
    }
    
    func deleteMonitoringArea(monitoringArea: MonitoringArea) {
        do {
            let realm = try Realm()
            let object = realm.objects(MonitoringArea.self).filter("localId = %@", monitoringArea.localId).first!
            RealmRequests.deleteObject(object)
        } catch _ {
            fatalError()
        }
    }
    
    func deletePastureAction(pastureAction: PastureAction) {
        do {
            let realm = try Realm()
            let object = realm.objects(PastureAction.self).filter("localId = %@", pastureAction.localId).first!
            RealmRequests.deleteObject(object)
        } catch _ {
            fatalError()
        }
    }
 }
 
 // MARK: Pasture
 extension RUPManager {
    func getPasturesArray(rup: RUP) -> [Pasture] {
        let ps = rup.pastures
        var returnVal = [Pasture]()
        for p in ps {
            returnVal.append(p)
        }
        return returnVal
    }
    
    func copyPasture(from: Pasture, to: Pasture) {
        to.allowedAUMs = from.allowedAUMs
        to.privateLandDeduction = from.privateLandDeduction
        to.graceDays = from.graceDays
        to.notes = from.notes
        RealmRequests.updateObject(to)
    }
    
    func deletePasture(pasture: Pasture) {
        // remove all schedule objects with this pasture
        do {
            let realm = try Realm()
            let scheduleObjects = realm.objects(ScheduleObject.self).filter("pasture = %@", pasture)
            for object in scheduleObjects {
                RealmRequests.deleteObject(object)
            }
        } catch _ {
            fatalError()
        }
        RealmRequests.deleteObject(pasture)
    }
    
    /*
     Sets a schedule object's related pasture object.
     used in lookupPastures in ScheduleObjectTableViewCell and
     should be re used in the future if a rup is downloaded.
     the calculations in the other functions in this extention
     rely on schedule objects being able to reference their assigned pastures.
     */
    func setPastureOn(scheduleObject: ScheduleObject, pastureName: String, rup: RUP) {
        guard let pasture = getPastureNamed(name: pastureName, rup: rup) else {return}
        do {
            let realm = try Realm()
            try realm.write {
                scheduleObject.pasture = pasture
                scheduleObject.graceDays = pasture.graceDays
            }
        } catch _ {
            fatalError()
        }
        calculateScheduleEntry(scheduleObject: scheduleObject)
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
    
    func getPlantCommunityAspectLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        
        for i in 0...3 {
            returnArray.append(SelectionPopUpObject(display: "option \(i)"))
        }
        
        return returnArray
    }
    
    func getPlantCommunityElevationLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "- <500"))
        returnArray.append(SelectionPopUpObject(display: "500-699"))
        returnArray.append(SelectionPopUpObject(display: "700-899"))
        returnArray.append(SelectionPopUpObject(display: "900-1099"))
        returnArray.append(SelectionPopUpObject(display: "1100-1299"))
        returnArray.append(SelectionPopUpObject(display: "1300-1500"))
        returnArray.append(SelectionPopUpObject(display: ">1500"))
        return returnArray
    }
    
    func getPlantCommunityPurposeOfActionsLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Establish Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Maintain Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Clear"))
        return returnArray
    }
    
    func getRangeLandHealthLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Highly at risk"))
        returnArray.append(SelectionPopUpObject(display: "Moderately at risk"))
        returnArray.append(SelectionPopUpObject(display: "Non-functional"))
        returnArray.append(SelectionPopUpObject(display: "Properly Functioning Condition"))
        returnArray.append(SelectionPopUpObject(display: "Slightly at risk"))
        return returnArray
    }
    
    func getMonitoringAreaPurposeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Key Area"))
        returnArray.append(SelectionPopUpObject(display: "Criteria"))
        returnArray.append(SelectionPopUpObject(display: "Other"))
        return returnArray
    }
    
    func getPastureActionLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Herding"))
        returnArray.append(SelectionPopUpObject(display: "Livestock variables"))
        returnArray.append(SelectionPopUpObject(display: "Salting"))
        returnArray.append(SelectionPopUpObject(display: "Supplemental"))
        returnArray.append(SelectionPopUpObject(display: "Timing"))
        returnArray.append(SelectionPopUpObject(display: "Other"))
        return returnArray
    }
    func getIndicatorPlantLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Pinegrass"))
        returnArray.append(SelectionPopUpObject(display: "Idaho Fescue"))
        return returnArray
    }
 }
 
 // MARK: Schedule
 extension RUPManager {
    func getScheduleYears(rup: RUP) -> [String] {
        let schedules = rup.schedules
        var years = [String]()
        for schedule in schedules {
            years.append("\(schedule.year)")
        }
        return years
    }
    
    func rupHasScheduleForYear(rup: RUP, year: Int) -> Bool {
        let schedules = rup.schedules
        for schedule in schedules {
            if schedule.year == year {
                return true
            }
        }
        return false
    }
    
    func copyScheduleObjects(from: Schedule, to: Schedule) {
        let toYear = to.year
        for object in from.scheduleObjects {
            let new = ScheduleObject()
            new.pasture = object.pasture
            new.liveStockTypeId = object.liveStockTypeId
            new.numberOfAnimals = object.numberOfAnimals
            
            if let dateIn = object.dateIn {
                new.dateIn = DateManager.update(date: dateIn, toYear: toYear)
            }
            
            if let dateOut = object.dateOut {
                new.dateOut = DateManager.update(date: dateOut, toYear: toYear)
            }
            
            new.totalAUMs = object.totalAUMs
            new.pldAUMs = object.pldAUMs
            new.scheduleDescription = object.scheduleDescription
            new.graceDays = object.graceDays
            
            RealmRequests.saveObject(object: new)
            to.scheduleObjects.append(new)
        }
        RealmRequests.updateObject(to)
    }
    
    func copyScheduleObject(fromObject: ScheduleObject, inSchedule: Schedule) {
        let new = ScheduleObject()
        new.pasture = fromObject.pasture
        new.liveStockTypeId = fromObject.liveStockTypeId
        new.numberOfAnimals = fromObject.numberOfAnimals
        new.dateIn = fromObject.dateIn
        new.dateOut = fromObject.dateOut
        new.totalAUMs = fromObject.totalAUMs
        new.pldAUMs = fromObject.pldAUMs
        new.scheduleDescription = fromObject.scheduleDescription
        new.graceDays = fromObject.graceDays
        new.isNew = true
        
        RealmRequests.saveObject(object: new)
        
        do {
            let realm = try Realm()
            try realm.write {
                inSchedule.scheduleObjects.append(new)
            }
        } catch _ {
            fatalError()
        }
    }
    
    func getUsageFor(year: Int, agreementId: String) -> RangeUsageYear? {
        guard let usage = RealmRequests.getObject(RangeUsageYear.self) else {
            return nil
        }
        
        let results = usage.filter { (usageForYear) in
            return usageForYear.agreementId == agreementId && usageForYear.year == year
        }
        
        return results.first
    }
    
    func calculateScheduleEntry(scheduleObject: ScheduleObject) {
        calculateTotalAUMsFor(scheduleObject: scheduleObject)
        calculatePLDFor(scheduleObject: scheduleObject)
    }
    
    func calculateTotalAUMsFor(scheduleObject: ScheduleObject) {
        var auFactor = 0.0
        // if animal type hasn't been selected, return 0
        let liveStockId = scheduleObject.liveStockTypeId
        if liveStockId != -1 {
            let liveStockObject = RealmManager.shared.getLiveStockTypeObject(id: liveStockId)
            auFactor = liveStockObject.auFactor
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
        if !scheduleHasValidEntries(schedule: schedule, agreementID: agreementID) {
            return false
        }
        // Last criteria: Total AUMs are within allowed AUMs for that year
        return totAUMs <= Double(allowed)
    }
    
    func scheduleHasValidEntries(schedule: Schedule, agreementID: String) -> Bool {
        /*
         - Schedule must have at least 1 valid entry.
         - Schedule entries must be valid.
         We Can rely on the toDictionary function of the schedule.
         if schedule objects are incomplete, toDictionary returns an empty
         array for key "grazingScheduleEntries"
         */
        let dictionary = schedule.toDictionary()
        let grazingEntries: [[String: Any]] = dictionary["grazingScheduleEntries"] as! [[String: Any]]
        if schedule.scheduleObjects.count < 1 || grazingEntries.count != schedule.scheduleObjects.count {
            return false
        } else {
            return true
        }
    }
    
    // Returns error messages
    func validateSchedule(schedule: Schedule, agreementID: String) -> (Bool, String) {
        if schedule.scheduleObjects.count < 1 {
            return (false, "Schedule must have at least 1 entry")
        }
        let dictionary = schedule.toDictionary()
        let grazingEntries: [[String: Any]] = dictionary["grazingScheduleEntries"] as! [[String: Any]]
        if grazingEntries.count != schedule.scheduleObjects.count {
            return (false, "Schedule has one or more invalid entries")
        }
        
        /*
         is valid schedule does check the above criteria,
         but if those have passed, and this still fails,
         its means that the total aums are more than the allowed aums
         */
        if !isScheduleValid(schedule: schedule, agreementID: agreementID) {
            return (false, "Total AUMs exceed the allowed amount for the this year")
        }
        
        return (true, "")
        
    }
    
    // if livestock with the specified name is not found, returns false
    func setLiveStockTypeFor(scheduleObject: ScheduleObject, liveStock: String) -> ScheduleObject {
        let ls = RealmManager.shared.getLiveStockTypeObject(name: liveStock)
        do {
            let realm = try Realm()
            let scheduleObj = realm.objects(ScheduleObject.self).filter("localId = %@", scheduleObject.localId).first!
            try realm.write {
                scheduleObj.liveStockTypeId = ls.id
            }
            return scheduleObj
        } catch _ {
            fatalError()
        }
    }
    
    func getSchedulesArray(rup: RUP) -> [Schedule] {
        let ss = rup.schedules
        var returnVal = [Schedule]()
        for s in ss {
            returnVal.append(s)
        }
        return returnVal
    }
    
    func isNewScheduleYearValidFor(rup: RUP, newYear: Int) -> Bool {
        
        guard let start = rup.planStartDate?.yearOfDate(), let end = rup.planEndDate?.yearOfDate() else {
            return false
        }
        
        // String array of years current schedule objects
        let years = rup.schedules.map({ (schedule) in
            return schedule.year
        }).filter({ (item) in
            return item == newYear
        })
        
        // if plan start and end dates are not selected
        if years.count > 0 || newYear < start || newYear > end {
            return false
        }
        
        return true
    }
    
    func getNextScheduleYearFor(from: Int, rup: RUP) -> Int? {
        // String array of years current schedule objects
        let years = rup.schedules.map({ (schedule) in
            return schedule.year
        }).sorted {$0 < $1}
        
        guard let planStart = rup.planStartDate?.yearOfDate() else { return nil}
        guard let plantEnd = rup.planEndDate?.yearOfDate() else { return nil}
        
        let y_forward = computeNextScheduleYearFor(from: from, to: plantEnd, taken: years)
        if isNewScheduleYearValidFor(rup: rup, newYear: y_forward) {
            return y_forward
        } else {
            let y_backwards = computeNextScheduleYearFor(from: planStart, to: plantEnd, taken: years)
            if isNewScheduleYearValidFor(rup: rup, newYear: y_backwards) {
                return y_backwards
            }
        }
        
        return nil
    }
    
    func computeNextScheduleYearFor(from: Int, to: Int,taken: [Int]) -> Int {
        var new = from
        
        // Find the next year that's not taken
        while taken.contains(new) && new <= to {
            new = new + 1
        }
        
        return new
    }
    
    func updateSchedulesForPasture(pasture: Pasture, in rup: RUP) {
        let query = RealmRequests.getObject(ScheduleObject.self)
        if let scheduleObjects = query {
            for object in scheduleObjects {
                if object.pasture?.localId == pasture.localId {
                    calculateScheduleEntry(scheduleObject: object)
                }
            }
        }
    }
    
    //    func getLiveStockIdentifierTypeFor(id: Int) -> LivestockIdentifierType {
    //        let query = RealmRequests.getObject(LivestockIdentifierType.self)
    //        if let all = query {
    //            for object in all {
    //                if object.id == id {
    //                    return object
    //                }
    //            }
    //        }
    //        return LivestockIdentifierType()
    //    }
    
 }
 
 // MARK: Minister's Issues and actions
 extension RUPManager {
    func removeIssue(issue: MinisterIssue) {
        for action in issue.actions {
            RealmRequests.deleteObject(action)
        }
        RealmRequests.deleteObject(issue)
    }
 }
 
 
 // MARK: Reference Data
 extension RUPManager {
    func getAllReferenceData() -> [Object] {
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
        
        return objects
    }
    
    func storeNewReferenceData(objects: [Object]) {
        for object in objects {
            RealmRequests.saveObject(object: object)
        }
    }
    
    func getStaffDraftPlanStatus() -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == "sd"  {
                    return object
                }
            }
        }
        return PlanStatus()
    }
    
    func getCreatedPlanStatus() -> PlanStatus {
        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == "c"  {
                    return object
                }
            }
        }
        return PlanStatus()
    }
    
    func getStatus(forId id: Int) -> PlanStatus? {
        do {
            let realm = try Realm()
            let statuses = realm.objects(PlanStatus.self).filter("id = %@", id)
            return statuses.first
        } catch _ {}
        return nil
    }
    
    func updateReferenceData(objects: [Object]) {
        clearStoredReferenceData()
        storeNewReferenceData(objects: objects)
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
    
    func clearStoredReferenceData() {
        let objects = getAllReferenceData()
        removeAllObjectsIn(query: objects)
    }
    
    func removeAllObjectsIn(query: [Object]?) {
        if query == nil {return}
        for object in query! {
            RealmRequests.deleteObject(object)
        }
    }
    
    func getClientTypeFor(clientTypeCode: String) -> ClientType {
        let query = RealmRequests.getObject(ClientType.self)
        if let all = query {
            for object in all {
                // while you're at it, clean up invalid data..
                if object.id == -1 {
                    RealmRequests.deleteObject(object)
                }
                if object.code == clientTypeCode {
                    return object
                }
            }
        }
        return ClientType()
    }
    
    func getMinistersIssueTypesOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = RealmManager.shared.getIssueType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }
    
    func getMinistersIssueActionsOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = RealmManager.shared.getIssueActionType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }
    
    func getIssueType(named: String) -> MinisterIssueType? {
        do {
            let realm = try Realm()
            if let obj = realm.objects(MinisterIssueType.self).filter("name = %@", named).first {
                return obj
            }
        } catch _ {
            fatalError()
        }
        return nil
    }
    
    func getIssueActionType(named: String) -> MinisterIssueActionType? {
        do {
            let realm = try Realm()
            if let obj = realm.objects(MinisterIssueActionType.self).filter("name = %@", named).first {
                return obj
            }
        } catch _ {
            fatalError()
        }
        return nil
    }
    
    func getPlanCommunityTypeOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        options.append(SelectionPopUpObject(display: "Pinegrass"))
        options.append(SelectionPopUpObject(display: "Something"))
        options.append(SelectionPopUpObject(display: "Something else"))
        return options
    }
 }
