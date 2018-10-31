//
//  ReferenceManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class Reference {
    static let shared = Reference()
    private init() {}
    
    func clearReferenceData() {
        let reference: [Object] = getReferenceData()
        for element in reference {
            RealmRequests.deleteObject(element)
        }
    }

    func getReferenceData() -> [Object] {
        var reference: [Object] = [Object]()
        reference.append(contentsOf: getLiveStockType())
        reference.append(contentsOf: getAgreementTypes())
        reference.append(contentsOf: getAgreementStatuses())
        reference.append(contentsOf: getClientTypes())
        reference.append(contentsOf: getPlanStatuses())
        reference.append(contentsOf: getAgreementExeptionStatuses())
        reference.append(contentsOf: getIssueType())
        reference.append(contentsOf: getIssueActionType())
        reference.append(contentsOf: getAmendmentTypes())
        reference.append(contentsOf: getPlantSpecies())
        reference.append(contentsOf: getPlantCommunityActionType())
        reference.append(contentsOf: getPlantCommunityElevation())
        reference.append(contentsOf: getPlantCommunityType())
        reference.append(contentsOf: getMonitoringAreaHealth())
        reference.append(contentsOf: getMonitoringAreaPurposeType())
        reference.append(contentsOf: getAdditionalRequirementCategory())
        reference.append(contentsOf: getManagegementConsiderationType())
        return reference
    }

    func updateReferenceData(objects: [Object]) {
        clearReferenceData()
        storeNewReferenceData(objects: objects)
    }

    func storeNewReferenceData(objects: [Object]) {
        for object in objects {
            RealmRequests.saveObject(object: object)
        }
    }

    func getClientTypes() -> [ClientType] {
        if let query = RealmRequests.getObject(ClientType.self) {
            return query
        } else {
            return [ClientType]()
        }
    }

    func getPlanStatuses() -> [PlanStatus] {
        if let query = RealmRequests.getObject(PlanStatus.self) {
            return query
        } else {
            return [PlanStatus]()
        }
    }

    func getAgreementExeptionStatuses() -> [AgreementExemptionStatus] {
        if let query = RealmRequests.getObject(AgreementExemptionStatus.self) {
            return query
        } else {
            return [AgreementExemptionStatus]()
        }
    }

    func getAgreementTypes() -> [AgreementType] {
        let query = RealmRequests.getObject(AgreementType.self)
        if query != nil {
            return query!
        } else {
            return [AgreementType]()
        }
    }

    func getAmendmentType(named: String) -> AmendmentType? {
        let all = getAmendmentTypes()
        for item in all where item.name.lowercased() == named.lowercased() {
            return item
        }
        return nil
    }

    func getAgreementStatuses() -> [AgreementStatus] {
        let query = RealmRequests.getObject(AgreementStatus.self)
        if query != nil {
            return query!
        } else {
            return [AgreementStatus]()
        }
    }

    func getLiveStockType() -> [LiveStockType] {
        let query = RealmRequests.getObject(LiveStockType.self)
        if query != nil {
            return query!
        } else {
            return [LiveStockType]()
        }
    }

    func getIssueType() -> [MinisterIssueType] {
        let query = RealmRequests.getObject(MinisterIssueType.self)
        if query != nil {
            return query!
        } else {
            return [MinisterIssueType]()
        }

    }

    func getIssueActionType() -> [MinisterIssueActionType] {
        let query = RealmRequests.getObject(MinisterIssueActionType.self)
        if query != nil {
            return query!
        } else {
            return [MinisterIssueActionType]()
        }
    }

    func getAmendmentTypes() -> [AmendmentType] {
        let query = RealmRequests.getObject(AmendmentType.self)
        if query != nil {
            return query!
        } else {
            return [AmendmentType]()
        }
    }


    func getPlantSpecies() -> [PlantSpecies] {
        let query = RealmRequests.getObject(PlantSpecies.self)
        if query != nil {
            return query!
        } else {
            return [PlantSpecies]()
        }
    }

    func getPlantCommunityType() -> [PlantCommunityType] {
        let query = RealmRequests.getObject(PlantCommunityType.self)
        if query != nil {
            return query!
        } else {
            return [PlantCommunityType]()
        }
    }

    func getPlantCommunityElevation() -> [PlantCommunityElevation] {
        let query = RealmRequests.getObject(PlantCommunityElevation.self)
        if query != nil {
            return query!
        } else {
            return [PlantCommunityElevation]()
        }
    }

    func getPlantCommunityActionType() -> [PlantCommunityActionType] {
        let query = RealmRequests.getObject(PlantCommunityActionType.self)
        if query != nil {
            return query!
        } else {
            return [PlantCommunityActionType]()
        }
    }

    func getMonitoringAreaHealth() -> [MonitoringAreaHealth] {
        let query = RealmRequests.getObject(MonitoringAreaHealth.self)
        if query != nil {
            return query!
        } else {
            return [MonitoringAreaHealth]()
        }
    }

    func getMonitoringAreaPurposeType() -> [MonitoringAreaPurposeType] {
        let query = RealmRequests.getObject(MonitoringAreaPurposeType.self)
//        let other = MonitoringAreaPurposeType()
//        other.name = "other"
//        query?.append(other)
        if query != nil {
            return query!
        } else {
            return [MonitoringAreaPurposeType]()
        }
    }

    func getManagegementConsiderationType() -> [ManagegementConsiderationType] {
        let query = RealmRequests.getObject(ManagegementConsiderationType.self)
        if query != nil {
            return query!
        } else {
            return [ManagegementConsiderationType]()
        }
    }

    func getAdditionalRequirementCategory() -> [AdditionalRequirementCategory] {
        let query = RealmRequests.getObject(AdditionalRequirementCategory.self)
        if query != nil {
            return query!
        } else {
            return [AdditionalRequirementCategory]()
        }
    }

    ////////////////////////
    func getAgreementTypeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = getAgreementTypes()
        for object in objects {
            returnArray.append(SelectionPopUpObject(display: object.desc, value:  object.desc))
        }
        return returnArray
    }

    func getLiveStockTypeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = getLiveStockType()
        for object in objects {
            returnArray.append(SelectionPopUpObject(display: object.name, value:  object.name))
        }
        return returnArray
    }

    func getLiveStockTypeObject(name: String) -> (LiveStockType) {
        let objects = getLiveStockType()
        for object in objects {
            if object.name.lowercased() == name.lowercased() {
                return object
            }
        }
        return LiveStockType()
    }

    func getLiveStockTypeObject(id: Int) -> (LiveStockType) {
        let objects = getLiveStockType()
        for object in objects {
            if object.id == id {
                return object
            }
        }
        return LiveStockType()
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

    func convertToPlanStatus(status: RUPStatus)  -> PlanStatus {
        var code = ""
        if status == .WronglyMadeWithoutEffect {
            code = "wm"
        } else if status == .StandsWronglyMade {
            code = "sw"
        } else if status == .Stands {
            code = "s"
        } else if status == .RecommendNotReady {
            code = "rnr"
        } else if status == .RecommendReady {
            code = "rr"
        } else if status == .NotApprovedFurtherWorkRequired {
            code = "nf"
        } else if status == .NotApproved {
            code = "na"
        } else if status == .Approved {
            code = "a"
        } else if status == .SubmittedForFinalDecision {
            code = "sfd"
        } else if status == .Pending {
            code = "P"
        } else if status == .Completed {
            code = "O"
        } else if status == .ChangeRequested {
            code = "R"
        } else if status == .StaffDraft {
            code = "SD"
        }

        let query = RealmRequests.getObject(PlanStatus.self)
        if let all = query {
            for object in all {
                if object.code.lowercased() == code.lowercased()  {
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

    func getAmendmentType(forId id: Int) -> AmendmentType? {
        do {
            let realm = try Realm()
            let statuses = realm.objects(AmendmentType.self).filter("id = %@", id)
            return statuses.first
        } catch _ {}
        return nil
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

    func getStatusTooltipDeescription(for status: RUPStatus) -> String {
        return "describing \(status) status etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc etc"
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

    func getIssueType(named: String) -> MinisterIssueType? {
        do {
            let realm = try Realm()
            if let obj = realm.objects(MinisterIssueType.self).filter("name = %@", named).first {
                return obj
            } else if let obj = realm.objects(MinisterIssueType.self).filter("name = %@", "Other").first {
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
            } else if let obj = realm.objects(MinisterIssueActionType.self).filter("name = %@", "Other").first {
                return obj
            }
        } catch _ {
            fatalError()
        }
        return nil
    }


    // MARK: Handling reference JSON
    func handleReference(json: JSON) -> [Object] {
        var referenceObjects = [Object]()
        referenceObjects.append(contentsOf: handleLiveStockType(json: json["LIVESTOCK_TYPE"]))
        referenceObjects.append(contentsOf: handleAgreementType(json: json["AGREEMENT_TYPE"]))
        referenceObjects.append(contentsOf: handleAgreementStatus(json: json["AGREEMENT_STATUS"]))
        referenceObjects.append(contentsOf: handleLivestockIdentifierType(json: json["LIVESTOCK_IDENTIFIER_TYPE"]))
        referenceObjects.append(contentsOf: handleClientType(json: json["CLIENT_TYPE"]))
        referenceObjects.append(contentsOf: handlePlanStatus(json: json["PLAN_STATUS"]))
        referenceObjects.append(contentsOf: handleAgreementExeptionStatus(json: json["AGREEMENT_EXEMPTION_STATUS"]))
        referenceObjects.append(contentsOf: handleMinisterIssueType(json: json["MINISTER_ISSUE_TYPE"]))
        referenceObjects.append(contentsOf: handleMinisterIssueActionType(json: json["MINISTER_ISSUE_ACTION_TYPE"]))
        referenceObjects.append(contentsOf: handleAmendmentType(json: json["AMENDMENT_TYPE"]))

        referenceObjects.append(contentsOf: handlePlantSpecies(json: json["PLANT_SPECIES"]))
        referenceObjects.append(contentsOf: handlePlantCommunityType(json: json["PLANT_COMMUNITY_TYPE"]))
        referenceObjects.append(contentsOf: handlePlantCommunityElevation(json: json["PLANT_COMMUNITY_ELEVATION"]))
        referenceObjects.append(contentsOf: handlePlantCommunityActionType(json: json["PLANT_COMMUNITY_ACTION_TYPE"]))
        referenceObjects.append(contentsOf: handleMonitoringAreaHealth(json: json["MONITORING_AREA_HEALTH"]))
        referenceObjects.append(contentsOf: handleMonitoringAreaPurposeType(json: json["MONITORING_AREA_PURPOSE_TYPE"]))
        referenceObjects.append(contentsOf: handleManagegementConsiderationType(json: json["MANAGEMENT_CONSIDERATION_TYPE"]))
        referenceObjects.append(contentsOf: handleAdditionalRequirementCategory(json: json["ADDITIONAL_REQUIREMENT_CATEGORY"]))
        return referenceObjects
    }

    func handleLivestockIdentifierType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = LivestockIdentifierType()
            if let desc = item["description"].string {
                obj.desc = desc
            }
            if let id = item["id"].int {
                obj.id = id
            }
            result.append(obj)
        }
        return result
    }

    func handleClientType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = ClientType()
            if let desc = item["description"].string {
                obj.desc = desc
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let code = item["code"].string {
                obj.code = code
            }
            result.append(obj)
        }
        return result
    }

    func handlePlanStatus(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = PlanStatus()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let code = item["code"].string {
                obj.code = code
            }
            result.append(obj)
        }
        return result
    }

    func handleAgreementExeptionStatus(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = AgreementExemptionStatus()
            if let desc = item["description"].string {
                obj.desc = desc
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let code = item["code"].string {
                obj.code = code
            }
            result.append(obj)
        }
        return result
    }

    func handleLiveStockType(json: JSON) -> [Object] {
        var result = [LiveStockType]()
        for (_,item) in json {
            let obj = LiveStockType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let auFactor = item["auFactor"].double {
                obj.auFactor = auFactor
            }
            result.append(obj)
        }

        // sort
        return result.sorted(by: { $0.id < $1.id })
    }

    func handleMinisterIssueType(json: JSON) -> [Object] {
        var result = [MinisterIssueType]()
        for (_,item) in json {
            let obj = MinisterIssueType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        // sort
        return result.sorted(by: { $0.id < $1.id })
    }

    func handleAmendmentType(json: JSON) -> [Object] {
        var result = [AmendmentType]()
        for (_,item) in json {
            let obj = AmendmentType()
            if let name = item["description"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        // sort
        return result.sorted(by: { $0.id < $1.id })
    }

    func handleMinisterIssueActionType(json: JSON) -> [Object] {
        var result = [MinisterIssueActionType]()
        for (_,item) in json {
            let obj = MinisterIssueActionType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        // sort
        return result.sorted(by: { $0.id < $1.id })
    }

    func handleAgreementStatus(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = AgreementStatus()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let code = item["code"].string {
                obj.code = code
            }
            result.append(obj)
        }
        return result
    }

    func handleAgreementType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = AgreementType()
            if let id = item["id"].int {
                obj.id = id
            }
            if let desc = item["description"].string {
                obj.desc = desc
            }
            if let code = item["auFactor"].string {
                obj.code = code
            }
            result.append(obj)
        }
        return result
    }

    func handlePlantSpecies(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = PlantSpecies()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }

            if let stubbleHeight = item["stubbleHeight"].double {
                obj.stubbleHeight = stubbleHeight
            }

            if let annualGrowth = item["annualGrowth"].double {
                obj.annualGrowth = annualGrowth
            }

            if let leafStage = item["leafStage"].double {
                obj.leafStage = leafStage
            }
            result.append(obj)
        }
        return result
    }

    func handlePlantCommunityType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = PlantCommunityType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handlePlantCommunityElevation(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = PlantCommunityElevation()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handlePlantCommunityActionType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = PlantCommunityActionType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handleMonitoringAreaHealth(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = MonitoringAreaHealth()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handleMonitoringAreaPurposeType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = MonitoringAreaPurposeType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handleAdditionalRequirementCategory(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = AdditionalRequirementCategory()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func handleManagegementConsiderationType(json: JSON) -> [Object] {
        var result = [Object]()
        for (_,item) in json {
            let obj = ManagegementConsiderationType()
            if let name = item["name"].string {
                obj.name = name
            }
            if let id = item["id"].int {
                obj.id = id
            }
            if let active = item["active"].bool {
                obj.active = active
            }
            result.append(obj)
        }
        return result
    }

    func getIndicatorPlant(named: String) -> PlantSpecies? {
        let all = getPlantSpecies()
        for plant in all where plant.name == named {
            return plant
        }

        for plant in all where plant.name.lowercased() == "other" {
            return plant
        }

        return nil
    }

    func getPlantCommunitType(named: String) -> PlantCommunityType? {
        let all = getPlantCommunityType()

        for community in all where community.name.lowercased() == named.lowercased() {
            return community
        }

        for community in all where community.name.lowercased() == "other" {
            return community
        }

        return nil
    }

    func getPlantCommunityActionType(named: String) -> PlantCommunityActionType? {
        let all = getPlantCommunityActionType()
        for each in all where each.name.lowercased() == named.lowercased() {
            return each
        }

        for each in all where each.name.lowercased() == "other" {
            return each
        }

        return nil
    }

    func getPlantCommunityElevation(named: String) -> PlantCommunityElevation? {
        let all = getPlantCommunityElevation()
        for elevation in all where elevation.name.lowercased() == named.lowercased() {
            return elevation
        }
        return nil
    }

    func getMonitoringAreaHealh(named: String) -> MonitoringAreaHealth? {
        let all = getMonitoringAreaHealth()
        for each in all where each.name.lowercased() == named.lowercased() {
            return each
        }
        return nil
    }

    func getMonitoringAreaPurposeType(named: String) -> MonitoringAreaPurposeType? {
        let all = getMonitoringAreaPurposeType()
        for each in all where each.name.lowercased() == named.lowercased() {
            return each
        }

        for each in all where each.name.lowercased() == "other" {
            return each
        }

        return nil
    }

    func getAdditionalRequirementCategory(named: String) -> AdditionalRequirementCategory? {
        let all = getAdditionalRequirementCategory()
        for each in all where each.name.lowercased() == named.lowercased() {
            return each
        }

        for each in all where each.name.lowercased() == "other" {
            return each
        }

        return nil
    }

    func getManagementConsideration(named: String) -> ManagegementConsiderationType? {
        let all = getManagegementConsiderationType()
        for each in all where each.name.lowercased() == named.lowercased() {
            return each
        }

        for each in all where each.name.lowercased() == "other" {
            return each
        }

        return nil
    }

}
