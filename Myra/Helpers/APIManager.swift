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
                handleLiveStockResponse(json: json["LIVESTOCK_TYPE"])
                handleAgreemenTypeResponse(json: json["AGREEMENT_TYPE"])
                handleAgreementStatusResponse(json: json["AGREEMENT_STATUS"])
                return completion(true)
            }else {
                return completion(false)
            }
        }
    }

    static func handleLiveStockResponse(json: JSON) {
        for (_,item) in json {
            let lv = LiveStockType()
            if let name = item["name"].string {
                lv.name = name
            }
            if let id = item["id"].int {
                lv.id = id
            }
            if let auFactor = item["auFactor"].double {
                lv.auFactor = auFactor
            }
            RealmRequests.saveObject(object: lv)
        }
    }

    static func handleAgreementStatusResponse(json: JSON) {
        for (_,item) in json {
            let astatus = AgreementStatus()
            if let name = item["name"].string {
                astatus.name = name
            }
            if let id = item["id"].int {
                astatus.id = id
            }
            if let code = item["code"].string {
                astatus.code = code
            }
            RealmRequests.saveObject(object: astatus)
        }
    }

    static func handleAgreemenTypeResponse(json: JSON) {
        for (_,item) in json {
            let aType = AgreementType()
            if let id = item["id"].int {
                aType.id = id
            }
            if let desc = item["description"].string {
                aType.desc = desc
            }
            if let code = item["auFactor"].string {
                aType.code = code
            }
            RealmRequests.saveObject(object: aType)
        }
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

    static func getAgreements(completion: @escaping (_ success: Bool,_ rups: [RUP]?) -> Void) {
        Alamofire.request(agreementEndpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                var rups: [RUP] = [RUP]()
                if let error = json["error"].string {
                    print(error)
                    return completion(false, nil)
                }

                for (_,agreementJSON) in json {
                    rups.append(handleAgreementJSON(rupJSON: agreementJSON))
                }

                return completion(true, rups)
            } else {
                return completion(false, nil)
            }
        }
    }

    static func handleAgreementJSON(rupJSON: JSON) -> RUP {
        // RUP object vars
        var status = ""
        var id = "-1"
        var planStartDate: Date?
        var rangeName: String = ""
        var agreementStartDate: Date?
        var updatedAt: Date?
        var exemptionStatus: Bool = false
        var agreementId: String = ""
        var planEndDate: Date?
        var agreementEndDate: Date?
        var notes: String = ""
        var typeID: Int = 0

        if let s = rupJSON["status"].string {
            status = s
        }

        if let type = rupJSON["typeId"].int {
            typeID = type
        }

        if let i = rupJSON["id"].string {
            id = i
        }

        if let d1 = rupJSON["planStartDate"].string {
            planStartDate = DateManager.fromUTC(string: d1)
        }

        if let rn = rupJSON["rangeName"].string {
            rangeName = rn
        }

        if let d2 = rupJSON["agreementStartDate"].string {
            agreementStartDate = DateManager.fromUTC(string: d2)
        }

        if let d3 = rupJSON["updatedAt"].string {
            updatedAt = DateManager.fromUTC(string: d3)
        }

        if let exm = rupJSON["exemptionStatus"].bool {
            exemptionStatus = exm
        }

        if let aid = rupJSON["agreementId"].string {
            agreementId = aid
        }

        if let d4 = rupJSON["planEndDate"].string {
            planEndDate = DateManager.fromUTC(string: d4)
        }

        if let d5 = rupJSON["agreementEndDate"].string {
            agreementEndDate = DateManager.fromUTC(string: d5)
        }

        if let nts = rupJSON["notes"].string {
            notes = nts
        }

        // Zone object vars
        let zoneJSON = rupJSON["zone"]

        var zid: Int = -1
        var zcode: String = ""
        var zdistrictId: Int = -1
        var zdesc: String = ""

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

        var usages = [RangeUsageYear]()
        let usageJSON = rupJSON["usage"]
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

        // District object vars
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
        zone.set(district: district, id: zid, code: zcode, districtId: zdistrictId, desc: zdesc)

        let rup = RUP()

        rup.set(id: id, status: status, zone: zone, planStartDate: planStartDate, rangeName: rangeName, agreementStartDate: agreementStartDate, updatedAt: updatedAt, exemptionStatus: exemptionStatus, agreementId: agreementId, planEndDate: planEndDate, agreementEndDate: agreementEndDate, notes: notes)
        for usage in sortedUsages {
            rup.rangeUsageYears.append(usage)
        }
        rup.typeId = typeID
        return rup
    }

}
extension APIManager {
    static func sync(completion: @escaping (_ done: Bool) -> Void, progress: @escaping (_ text: String)-> Void) {
        progress("veryfying connection")
        if let r = Reachability(), r.connection != .none {
            progress("Downloading reference data")
            getReferenceData(completion: { (success) in
                if success {
                    progress("Downloading agreements")
                    getAgreements(completion: { (done, rups) in
                        if done {
                            progress("Updating stored data")
                            RUPManager.shared.diffAgreements(rups: rups!)
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
//                switch response.result {
//                case .success(let value):
//                    if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
//                        print("The request failed")
//                        print("Error: \(String(describing: json["error"] as? String ?? "No message provided"))")
//                    }
//                    completion(true)
//                case .failure(let error):
//                    completion(false)
//                }f
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
