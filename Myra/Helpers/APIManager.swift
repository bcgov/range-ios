//
//  APIManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Reachability
import SingleSignOn
import Realm
import RealmSwift

class APIManager {

    static let baseURL = "http://api-range-myra-dev.pathfinder.gov.bc.ca/v1"
    static let agreementEndpoint = "\(baseURL)/agreement"
    static let planEndpoint = "\(baseURL)/plan"
    static let reference = "\(baseURL)/reference"

    static let authServices: AuthServices = {
        return AuthServices(baseUrl: SingleSignOnConstants.SSO.baseUrl, redirectUri: SingleSignOnConstants.SSO.redirectUri,
                            clientId: SingleSignOnConstants.SSO.clientId, realm:SingleSignOnConstants.SSO.realmName,
                            idpHint: SingleSignOnConstants.SSO.idpHint)
    }()


    static func headers() -> HTTPHeaders {
        if let creds = authServices.credentials {
            let token = creds.accessToken
            return ["Content-Type" : "application/json", "Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type" : "application/json"]
        }
    }

    static func getReferenceData(completion: @escaping (_ success: Bool) -> Void) {
        RealmManager.shared.clearReferenceData()
        Alamofire.request(reference, method: .get, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                var newReference = [Object]()
                newReference.append(contentsOf: handle_LIVESTOCK_TYPE(json: json["LIVESTOCK_TYPE"]))
                newReference.append(contentsOf: handle_AGREEMENT_TYPE(json: json["AGREEMENT_TYPE"]))
                newReference.append(contentsOf: handle_AGREEMENT_STATUS(json: json["AGREEMENT_STATUS"]))
                newReference.append(contentsOf: handle_LIVESTOCK_IDENTIFIER_TYPE(json: json["LIVESTOCK_IDENTIFIER_TYPE"]))
                newReference.append(contentsOf: handle_CLIENT_TYPE(json:json["CLIENT_TYPE"]))
                newReference.append(contentsOf: handle_PLAN_STATUS(json:json["PLAN_STATUS"]))
                newReference.append(contentsOf: handle_AGREEMENT_EXEMPTION_STATUS(json: json["AGREEMENT_EXEMPTION_STATUS"]))
                RUPManager.shared.updateReferenceData(objects: newReference)
                return completion(true)
            }else {
                return completion(false)
            }
        }
    }

    static func handle_LIVESTOCK_IDENTIFIER_TYPE(json: JSON) -> [Object] {
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
//            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func handle_CLIENT_TYPE(json: JSON) -> [Object] {
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func handle_PLAN_STATUS(json: JSON) -> [Object] {
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }
    static func handle_AGREEMENT_EXEMPTION_STATUS(json: JSON) -> [Object] {
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func handle_LIVESTOCK_TYPE(json: JSON) -> [Object] {
        var result = [Object]()
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func handle_AGREEMENT_STATUS(json: JSON) -> [Object] {
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func handle_AGREEMENT_TYPE(json: JSON) -> [Object] {
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
            //            RealmRequests.saveObject(object: obj)
        }
        return result
    }

    static func send(rup: RUP,completion: @escaping (_ success: Bool) -> Void) {
        let url = "\(agreementEndpoint)/\(rup.id)"
        var params: [String: Any] = [String: Any]()
        if let ps = rup.planStartDate {
            let start = DateManager.toUTC(date: ps)
            params["planStartDate"] = start
        }

        if let pe = rup.planEndDate {
            let end = DateManager.toUTC(date: pe)
            params["planEndDate"] = end
        }

        let headers = ["Content-Type":"application/json"]

        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            if response.result.description == "SUCCESS" {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }

    static func getAgreements(completion: @escaping (_ success: Bool,_ rups: [Agreement]?) -> Void) {
        print(headers())
        var agreements: [Agreement] = [Agreement]()
        Alamofire.request(agreementEndpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                if let error = json["error"].string {
                    print(error)
                    return completion(false, nil)
                }


                for (_,agreementJSON) in json {
                    agreements.append(handleAgreementJSON(agreementJSON: agreementJSON))
                }

                return completion(true, agreements)
            } else {
                return completion(false, agreements)
            }
        }
    }

    static func handleAgreementJSON(agreementJSON: JSON) -> Agreement {
        // Agreement Object vars
        var agreementId: String = ""
        var agreementStartDate: Date?
        var agreementEndDate: Date?
        var typeId: Int = -1
        var exemptionStatusId: Int = -1
        var createdAt: Date?
        var updatedAt: Date?

        if let i = agreementJSON["id"].string {
            agreementId = i
        }

        if let dateStart = agreementJSON["agreementStartDate"].string {
            agreementStartDate = DateManager.fromUTC(string: dateStart)
        }

        if let dateEnd = agreementJSON["agreementEndDate"].string {
            agreementEndDate = DateManager.fromUTC(string: dateEnd)
        }

        if let type = agreementJSON["typeId"].int {
            typeId = type
        }

        if let dateCreate = agreementJSON["createdAt"].string {
            createdAt = DateManager.fromUTC(string: dateCreate)
        }

        if let dateUpdate = agreementJSON["updatedAt"].string {
            updatedAt = DateManager.fromUTC(string: dateUpdate)
        }

        if let exemptionStatusNumber = agreementJSON["exemptionStatusId"].int {
            exemptionStatusId = exemptionStatusNumber
        }

        // Zone object
        let zoneJSON = agreementJSON["zone"]

        var zid: Int = -1
        var zcode: String = ""
        var zdistrictId: Int = -1
        var zdesc: String = ""

        var zcontactName = ""
        var zcontactPhoneNumber = ""
        var zcontactEmail = ""

        if let zd = zoneJSON["id"].int {
            zid = zd
        }
        if let zc = zoneJSON["code"].string {
            zcode = zc
        }
        if let zdid = zoneJSON["districtId"].int {
            zdistrictId = zdid
        }
        if let zdes = zoneJSON["description"].string {
            zdesc = zdes
        }
        if let zcn = zoneJSON["contactName"].string {
            zcontactName = zcn
        }
        if let zpn = zoneJSON["contactPhoneNumber"].string {
            zcontactPhoneNumber = zpn
        }
        if let zce = zoneJSON["contactEmail"].string {
            zcontactEmail = zce
        }

        // District object
        let districtJSON = zoneJSON["district"]
        var did: Int = -1
        var ddesc: String = ""
        var dcode: String = ""


        if let distId = districtJSON["id"].int {
            did = distId
        }
        if let distDesc = districtJSON["description"].string {
            ddesc = distDesc
        }
        if let distCode = districtJSON["code"].string {
            dcode = distCode
        }

        let district = District()
        district.set(id: did, code: dcode, desc: ddesc)

        let zone = Zone()
        zone.set(district: district, id: zid, code: zcode, districtId: zdistrictId, desc: zdesc, contactName: zcontactName, contactPhoneNumber: zcontactPhoneNumber, contactEmail: zcontactEmail)

        // Usage year objects
        var usages: [RangeUsageYear] = [RangeUsageYear]()
        let usageJSON = agreementJSON["usage"]
        for (_,usage) in usageJSON {
            let usageObj = RangeUsageYear()

            if let authAUM = usage["authorizedAum"].int {
                usageObj.auth_AUMs = authAUM
            }

            if let uid = usage["id"].int {
                usageObj.id = uid
            }

            if let tAU = usage["totalAnnualUse"].int{
                usageObj.totalAnnual = tAU
            }

            if let ti = usage["temporaryIncrease"].int {
                usageObj.tempIncrease = ti
            }

            if let tnu = usage["totalNonUse"].int {
                usageObj.totalNonUse = tnu
            }

            if let agid = usage["agreementId"].string {
                usageObj.agreementId = agid
            }

            if let yy = usage["year"].string {
                if yy.isInt {
                    usageObj.year = Int(yy)!
                }
            }
            usages.append(usageObj)
        }

        let sortedUsages = usages.sorted(by: { $0.year < $1.year })

        // Clients
        let clientsJSON = agreementJSON["clients"]
        var clients: [Client] = [Client]()
        for (_,clientJSON) in clientsJSON {
            let client = Client()

            if let cid = clientJSON["id"].string {
                client.id = cid
            }

            if let cname = clientJSON["name"].string {
                client.name = cname
            }

            if let clocationCode = clientJSON["locationCode"].string {
                client.locationCode = clocationCode
            }

            if let cstart = clientJSON["startDate"].string {
                client.startDate = DateManager.fromUTC(string: cstart)
            }

            if let cclientTypeCode = clientJSON["clientTypeCode"].string {
                client.clientTypeCode = cclientTypeCode
            }
            clients.append(client)
        }

        let agreement = Agreement()
        agreement.set(agreementId: agreementId, agreementStartDate: agreementStartDate!, agreementEndDate: agreementEndDate!, typeId: typeId, exemptionStatusId: exemptionStatusId, createdAt: createdAt, updatedAt: updatedAt)

        for usage in sortedUsages {
            agreement.rangeUsageYears.append(usage)
        }

        for client in clients {
            agreement.clients.append(client)
        }

        agreement.zones.append(zone)

        print(agreement)

        return agreement
    }
}

extension APIManager {
    static func sync(completion: @escaping (_ done: Bool) -> Void, progress: @escaping (_ text: String)-> Void) {
        progress("veryfying connection")
        if let r = Reachability(), r.connection != .none {
            progress("Downloading reference data")
            getReferenceData(completion: { (success) in
                if success {
                    // todo: remove call to print
                    progress("Downloading agreements")
                    getAgreements(completion: { (done, agreements) in
                        if done {
                            progress("Updating stored data")
                            RUPManager.shared.diffAgreements(agreements: agreements!)
                            //                            RUPManager.shared.diffAgreements(rups: rups!)
                            progress("Completed")
                            RealmManager.shared.updateLastSyncDate(date: Date(), DownloadedReference: true)
                            return completion(true)
                        } else {
                            progress("Failed while downloading agreements")
                            return completion(false)
                        }
                    })
                } else {
                    progress("Failed while downloading reference data")
                    return completion(false)
                }
            })
        } else {
            progress("Failed while verifying connection")
            return completion(false)
        }
    }

    static func uploadRUP(rup: RUP, completion: @escaping (_ done: Bool) -> Void) {
        Alamofire.request(planEndpoint, method: .post, parameters: rup.toJSON(), encoding: JSONEncoding.default, headers: headers())
            .responseData{ response in
                if response.result.description == "SUCCESS" {
                    let json = JSON(response.result.value!)
                    if let id = json["id"].int {
                        do {
                            let realm = try Realm()
                            try realm.write {
                                rup.dbID = id
                            }
                        } catch _ {
                            return completion(false)
                        }
                        let pastures = RUPManager.shared.getPasturesArray(rup: rup)
                        recursivePastureUpload(pastures: pastures, planID: id, completion: { (success) in
                            if success {
                                let schedules = RUPManager.shared.getSchedulesArray(rup: rup)
                                recursiveScheduleUpload(schedules: schedules, planID: id, completion: { (success) in
                                    if success {
                                        completion(true)
                                    } else {
                                        completion(false)
                                    }
                                })
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
        }
    }

    static func recursiveScheduleUpload(schedules: [Schedule], planID: Int,completion: @escaping (_ done: Bool) -> Void) {
        if schedules.count <= 0 {
            return completion(true)
        }

        var all = schedules
        let schedule = all.last
        all.removeLast()
        uploadSchedule(schedule: schedule!, planID: planID) { (done) in
            if done {
                recursiveScheduleUpload(schedules: all, planID: planID, completion: completion)
            } else {
                return completion(false)
            }
        }
    }

    static func uploadSchedule(schedule: Schedule, planID: Int,completion: @escaping (_ done: Bool) -> Void) {
        let url = "\(planEndpoint)/\(planID)/schedule"
        let param = schedule.toJSON()
        Alamofire.request(url, method: .post, parameters: param, encoding:  JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                if let id = json["id"].int {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            schedule.dbID = id
                        }
                        return completion(true)
                    } catch _ {
                        return completion(false)
                    }
                } else {
                    return completion(false)
                }
            } else {
                return completion(false)
            }
        }
    }

    static func recursivePastureUpload(pastures: [Pasture], planID: Int,completion: @escaping (_ done: Bool) -> Void) {
        if pastures.count <= 0 {
            return completion(true)
        }

        var all = pastures
        let pasture = all.last
        all.removeLast()
        uploadPasture(pasture: pasture!, planID: planID) { (done) in
            if done {
                recursivePastureUpload(pastures: all, planID: planID, completion: completion)
            } else {
                return completion(false)
            }
        }
    }

    static func uploadPasture(pasture: Pasture, planID: Int,completion: @escaping (_ done: Bool) -> Void) {
        let url = "\(planEndpoint)/\(planID)/pasture"
        let param = pasture.toJSON(planID: planID)
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                if let id = json["id"].int {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            pasture.dbID = id
                        }
                        return completion(true)
                    } catch _ {
                        return completion(false)
                    }
                } else {
                    return completion(false)
                }
            } else {
                return completion(false)
            }
        }
    }
}
