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
 import Extended
 
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

    /*
     Finds plans that are not linked to an agreement and links them to the appropriate agreements
     */
    func fixUnlinkedPlans() {
        let plans = getRUPs()
        let agreements = getAgreements()
        // get agreement numbers with no plans
        var agreementsWithNoPlans: [String] = [String]()
        for agreement in agreements where agreement.rups.count == 0 {
            agreementsWithNoPlans.append(agreement.agreementId)
        }

        // for each plan, if has an agreement number that's included in agreementsWithNoPlans, add it to agreement
        for plan in plans where agreementsWithNoPlans.contains(plan.agreementId) {
            if let temp = getAgreement(with: plan.agreementId) {
                do {
                    let realm = try Realm()
                    try realm.write {
                        temp.rups.append(plan)
                        for element in temp.rangeUsageYears {
                            plan.rangeUsageYears.append(element)
                        }
                        for element in temp.clients {
                            plan.clients.append(element)
                        }
                        for element in temp.zones {
                            plan.zones.append(element)
                        }
                    }
                } catch _ {
                    fatalError()
                }
            }
        }
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

        // check minister approval on pastures
        for pasture in rup.pastures {
            for community in pasture.plantCommunities {
                if !community.approvedByMinister {
                    return(false, "One or more plant communities is missing minister's approval")
                }
            }
        }

        return checkRequiredFields(in: rup)
    }

    func checkRequiredFields(in rup: RUP) -> (Bool, String) {

        if rup.planStartDate == nil {
            return (false, "Plan start date is missing")
        }

        if rup.planEndDate == nil {
            return (false, "Plan End date is missing")
        }

        if rup.rangeName.isEmpty {
            return (false, "Range Name is missing")
        }

        if rup.pastures.count < 1 {
            return (false, "You must add at least 1 Pasture")
        }

        // Pastures
        for pasture in rup.pastures {
            if !pasture.requiredFieldsAreFilled() {
                return (false, "One or more Pasture's required fields are missing")
            }
            for pc in pasture.plantCommunities {
                if !pc.requiredFieldsAreFilled() {
                    return (false, "One or more Plant communities' required fields are missing.\nIn Pasture: \(pasture.name),\n In Plant Community: \(pc.name)")
                }
                for ma in pc.monitoringAreas where !ma.requiredFieldsAreFilled() {
                    return (false, "One or more Monitoring Areas' required fields are missing.\nIn Pasture: \(pasture.name),\n In Plant Community: \(pc.name)")
                }
            }
        }

        for schedule in rup.schedules {
            for entry in schedule.scheduleObjects where !entry.requiredFieldsAreFilled() {
                return (false, "One or more Schedule entries' required fields are missing")
            }
        }

        for issue in rup.ministerIssues {
            if !issue.requiredFieldsAreFilled() {
                return (false, "One of more Minister's Issues' required fields are missing")
            }
            for action in issue.actions where !action.requiredFieldsAreFilled(){
                return (false, "One of more Minister's Issues' Action's required fields are missing")
            }
        }

        for invasivePlants in rup.invasivePlants where !invasivePlants.requiredFieldsAreFilled() {
            return (false, "Missing required fields in Invasive Plants section")
        }

        for req in rup.additionalRequirements where !req.requiredFieldsAreFilled() {
            return (false, "One of more Additional requirement's required fields are missing")
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
            for storedAgreement in storedAgreements where storedAgreement.agreementId == id {
                return storedAgreement
            }
        }
        return nil
    }

    func getAgreements(with id: String) -> [Agreement] {
        var found = [Agreement]()
        if let storedAgreements = RealmRequests.getObject(Agreement.self) {
            for storedAgreement in storedAgreements where storedAgreement.agreementId == id {
                found.append(storedAgreement)
            }
        }
        return found
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

    func getPlansWith(remoteId: Int) -> [RUP] {
        var found = [RUP]()
        guard let plans = RealmRequests.getObject(RUP.self) else {return found}
        for plan in plans where plan.remoteId == remoteId {
            found.append(plan)
        }
        return found
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

    func getRUPsWithUpdatedLocalStatus() -> [RUP] {
        var found = [RUP]()
        let all = getRUPs()
        for element in all where element.shouldUpdateRemoteStatus {
            found.append(element)
        }
        return found
    }
    
    func getDraftRups() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'LocalDraft'").map{ $0 }
            return Array(objs)
        } catch _ {}
        return [RUP]()
    }

    func getDraftRupsValidForUpload() -> [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'LocalDraft'").map{ $0 }
            var valid = [RUP]()
            for object in objs where object.planEndDate != nil && object.planStartDate != nil && object.rangeName != nil {
                valid.append(object)
            }
            return valid
        } catch _ {}
        return [RUP]()
    }

    func getStaffDraftRups() ->  [RUP] {
        do {
            let realm = try Realm()
            let objs = realm.objects(RUP.self).filter("status == 'StaffDraft'").map{ $0 }
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
        scheduleObject.calculateAUMsAndPLD()
    }
    
    func getPastureNamed(name: String, rup: RUP) -> Pasture? {
        for pasture in rup.pastures {
            if pasture.name == name {
                return pasture
            }
        }
        return nil
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
    
    func isScheduleValid(schedule: Schedule, agreementID: String) -> Bool {
        let totAUMs = schedule.getTotalAUMs()
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
        let ls = Reference.shared.getLiveStockTypeObject(name: liveStock)
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
        
        guard let start = rup.planStartDate?.year(), let end = rup.planEndDate?.year() else {
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
        
        guard let planStart = rup.planStartDate?.year() else { return nil}
        guard let plantEnd = rup.planEndDate?.year() else { return nil}
        
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
                if let entryPatrue = object.pasture, entryPatrue.localId == pasture.localId {
                    object.calculateAUMsAndPLD()
                }
            }
        }
    }
    
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
