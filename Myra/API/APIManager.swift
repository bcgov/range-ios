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

    static let baseURL = "http://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1"
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
            return ["Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type" : "application/json"]
        }
    }
    
    static func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let credentials = authServices.credentials {
            request.setValue("\(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }

    static func getReferenceData(completion: @escaping (_ success: Bool) -> Void) {
        RealmManager.shared.clearReferenceData()
        Alamofire.request(reference, method: .get, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                var newReference = [Object]()
                newReference.append(contentsOf: handleLiveStockType(json: json["LIVESTOCK_TYPE"]))
                newReference.append(contentsOf: handleAgreementType(json: json["AGREEMENT_TYPE"]))
                newReference.append(contentsOf: handleAgreementStatus(json: json["AGREEMENT_STATUS"]))
                newReference.append(contentsOf: handleLivestockIdentifierType(json: json["LIVESTOCK_IDENTIFIER_TYPE"]))
                newReference.append(contentsOf: handleClientType(json:json["CLIENT_TYPE"]))
                newReference.append(contentsOf: handlePlanStatus(json:json["PLAN_STATUS"]))
                newReference.append(contentsOf: handleAgreementExeptionStatus(json: json["AGREEMENT_EXEMPTION_STATUS"]))
                RUPManager.shared.updateReferenceData(objects: newReference)
                return completion(true)
            }else {
                return completion(false)
            }
        }
    }
    
    static func add(plan: RUP, toAgreement agreementId: String, completion: @escaping (_ plan: [String: Any]?, _ error: Error?) -> ()) {
        
        guard let endpoint = URL(string: Constants.API.planPath, relativeTo: Constants.API.baseURL!) else {
            return
        }

        // Were on a new thread now !
        guard let myPlan = DataServices.plan(withLocalId: plan.localId) else {
            return completion(nil, nil)
        }

//        let endpoint = "http://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/plan"

        var params = myPlan.toDictionary()
        params["agreementId"] = agreementId

        print(endpoint)
        print(params)
        
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
            switch response.result {
            case .success(let value):
                let j = JSON(value)
                if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
                    print("The request failed.")
                    print("Error: \(String(describing: json["error"] as? String ?? "No message provided"))")
                    completion(nil, nil)
                }
                
                completion(value as? [String: Any], nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    static func add(pasture: Pasture, toPlan planId: String, completion: @escaping (_ pasture: [String:Any]?, _ error: Error?) -> ()) {
        
        let pathKey = ":id"
        let path = Constants.API.pasturePath.replacingOccurrences(of: pathKey, with: planId, options: .literal, range: nil)
        
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        
        let params = pasture.toDictionary()

        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
                        print("The request failed.")
                        print("Error: \(String(describing: json["error"] as? String ?? "No message provided"))")
                        completion(nil, nil)
                    }
                    
                    completion(value as? [String: Any], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }

    static func add(schedule: Schedule, toPlan planId: String, completion: @escaping (_ pasture: [String:Any]?, _ error: Error?) -> ()) {

        let pathKey = ":id"
        let path = Constants.API.schedulePath.replacingOccurrences(of: pathKey, with: planId, options: .literal, range: nil)

        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }

        var params = schedule.toDictionary()
        params["plan_id"] = planId

        print(params)

        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in

                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
                        print("The request failed.")
                        print("Error: \(String(describing: json["error"] as? String ?? "No message provided"))")
                        completion(nil, nil)
                    }

                    completion(value as? [String: Any], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }

//    static func add(pastures: [Pasture], toPlan planId: String, completion: @escaping (_ pastures: [Pasture]?, _ error: Error?) -> ()) {
//
//        let pathKey = ":id"
//        let path = Constants.API.pasturePath.replacingOccurrences(of: pathKey, with: planId, options: .literal, range: nil)
//
//        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
//            return
//        }
//
//        var request = APIManager.request(url: endpoint)
//        request.httpBody = try! JSONSerialization.data(withJSONObject: pastures.map { $0.toDictionary() })
//
//        Alamofire.request(request).responseJSON { response in
//
//                switch response.result {
//                case .success(let value):
//                    if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
//                        print("The request failed.")
//                        print("Error: \(String(describing: json["error"] as? String ?? "No message provided"))")
//                        completion(nil, nil)
//                    }
//
//                    completion(nil, nil)
//                case .failure(let error):
//                    completion(nil, error)
//                }
//        }
//    }

    //
    // Everythign below here needs to be refactored or moved !!!
    //
    
    static func handleLivestockIdentifierType(json: JSON) -> [Object] {
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

    static func handleClientType(json: JSON) -> [Object] {
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

    static func handlePlanStatus(json: JSON) -> [Object] {
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

    static func handleAgreementExeptionStatus(json: JSON) -> [Object] {
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

    static func handleLiveStockType(json: JSON) -> [Object] {
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
        }
        return result
    }

    static func handleAgreementStatus(json: JSON) -> [Object] {
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

    static func handleAgreementType(json: JSON) -> [Object] {
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


//    static func send(rup: RUP,completion: @escaping (_ success: Bool) -> Void) {
//        let url = "\(agreementEndpoint)/\(rup.id)"
//        var params: [String: Any] = [String: Any]()
//        if let ps = rup.planStartDate {
//            let start = DateManager.toUTC(date: ps)
//            params["planStartDate"] = start
//        }
//
//        if let pe = rup.planEndDate {
//            let end = DateManager.toUTC(date: pe)
//            params["planEndDate"] = end
//        }
//
//        let headers = ["Content-Type":"application/json"]
//
//        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
//            if response.result.description == "SUCCESS" {
//                return completion(true)
//            } else {
//                return completion(false)
//            }
//        }
//    }

    static func getAgreements(completion: @escaping (_ success: Bool,_ rups: [Agreement]?) -> Void) {
        print(headers())
        var agreements: [Agreement] = [Agreement]()
        Alamofire.request(agreementEndpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
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
            usageObj.agreementId = agreementId
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
    static func sync(completion: @escaping (_ done: Bool) -> Void, progress: @escaping (_ text: String) -> Void) {
        
        guard let r = Reachability(), r.connection != .none else {
            progress("Failed while verifying connection")
            completion(false)
            return
        }
        
        var myAgreements: [Agreement]?
        let dispatchGroup = DispatchGroup()


        // Feature not yet implemented
//        dispatchGroup.enter()
//        progress("Uploading data to the server")
//        DataServices.shared.uploadDraftRangeUsePlans {
//            print("done like dinner")
//            dispatchGroup.leave()
//        }


        dispatchGroup.enter()
        progress("Uploading data to the server")
        DataServices.shared.uploadOutboxRangeUsePlans {
            progress("Downloading reference data")
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        progress("Downloading reference data")
        getReferenceData(completion: { (success) in
            if (!success) {
                progress("Failed while downloading reference data")
            }

            dispatchGroup.leave()
        })

        dispatchGroup.enter()
        progress("Downloading agreements")
        getAgreements(completion: { (done, agreements) in

            myAgreements = agreements

            if !done {
                progress("Failed while downloading agreements")
            } else {
                progress("Completed")
            }

            dispatchGroup.leave()
        })

        dispatchGroup.notify(queue: .main) {
            if let agreements = myAgreements {
                progress("Updating stored data")
                RUPManager.shared.diffAgreements(agreements: agreements)
                progress("Completed")
                RealmManager.shared.updateLastSyncDate(date: Date(), DownloadedReference: true)
            }
            
            completion(true)
        }
    }

    static func uploadRUP(rup: RUP, completion: @escaping (_ done: Bool) -> Void) {
        Alamofire.request(planEndpoint, method: .post, parameters: rup.toDictionary(), encoding: JSONEncoding.default, headers: headers())
            .responseData{ response in
                if response.result.description == "SUCCESS" {
                    let json = JSON(response.result.value!)
                    if let id = json["id"].int {
                        do {
                            let realm = try Realm()
                            try realm.write {
                                rup.remoteId = id
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
                                        return completion(true)
                                    } else {
                                        return completion(false)
                                    }
                                })
                                return completion(true)
                            } else {
                                return completion(false)
                            }
                        })
                    } else {
                        return completion(false)
                    }
                } else {
                    return completion(false)
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
        let param = schedule.toDictionary()
        Alamofire.request(url, method: .post, parameters: param, encoding:  JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                if let id = json["id"].int {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            schedule.remoteId = id
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
        let param = pasture.toDictionary()
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                print(json)
                if let id = json["id"].int {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            pasture.remoteId = id
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
