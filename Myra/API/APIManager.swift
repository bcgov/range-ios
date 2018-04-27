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

protocol LocalizedDescriptionError: Error {
    var localizedDescription: String { get }
}

public enum APIError: LocalizedDescriptionError {
    case unknownError
    case somethingHappened(message: String)
    case requestFailed(error: Error)
    
    var localizedDescription: String {
        switch self {
        case .somethingHappened(message: let message):
            return message
        default:
            return "No Error Provided"
        }
    }
}

class APIManager {

    typealias APIRequestCompleted = (_ records: [String:Any]?, _ error: APIError?) -> ()

    static let authServices: AuthServices = {
        return AuthServices(baseUrl: Constants.SSO.baseUrl, redirectUri: Constants.SSO.redirectUri,
                            clientId: Constants.SSO.clientId, realm: Constants.SSO.realmName,
                            idpHint: Constants.SSO.idpHint)
    }()

    static func headers() -> HTTPHeaders {
        if let creds = authServices.credentials {
            let token = creds.accessToken
            return ["Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type" : "application/json"]
        }
    }

    static func process(response: Alamofire.DataResponse<Any>, completion: APIRequestCompleted) {
        switch response.result {
        case .success(let value):
            if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
                let err = APIError.somethingHappened(message: "\(String(describing: json["error"] as? String))")
                print("Request Failed, error = \(err.localizedDescription)")
                completion(nil, err)
            }
            
            completion(value as? [String: Any], nil)
        case .failure(let error):
            completion(nil, APIError.requestFailed(error: error))
        }
    }

    static func getReferenceData(completion: @escaping (_ success: Bool) -> Void) {
        
        guard let endpoint = URL(string: Constants.API.referencePath, relativeTo: Constants.API.baseURL!) else {
            return
        }
        
        RealmManager.shared.clearReferenceData()
        Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
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

        var params = myPlan.toDictionary()
        params["agreementId"] = agreementId
        
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                APIManager.process(response: response, completion: completion)
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
                APIManager.process(response: response, completion: completion)
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
                APIManager.process(response: response, completion: completion)
        }
    }
    
//    static func getAgreements(completion: @escaping APIRequestCompleted) {
//
//        guard let endpoint = URL(string: Constants.API.agreementPath, relativeTo: Constants.API.baseURL!) else {
//            return
//        }
//
//        Alamofire.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers())
//            .responseJSON { response in
//                APIManager.process(response: response, completion: completion)
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

    static func getAgreements(completion: @escaping (_ rups: [Agreement]?, _ error: APIError?) -> Void) {
        
        guard let endpoint = URL(string: Constants.API.agreementPath, relativeTo: Constants.API.baseURL!) else {
            return
        }

        // TODO: Update error response type to use APIError (above)
        var agreements: [Agreement] = [Agreement]()
        Alamofire.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                if let error = json["error"].string {
                    print(error)
                    let err = APIError.somethingHappened(message: "\(String(describing: error))")
                    return completion(nil, err)
                }

                for (_,agreementJSON) in json {
                    agreements.append(handleAgreementJSON(agreementJSON: agreementJSON))
                }

                return completion(agreements, nil)
            } else {
                return completion(agreements, nil)
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
        getAgreements(completion: { (agreements, error) in

            if let error = error {
                progress("Sync Failed. \(error.localizedDescription)")
            } else {
                myAgreements = agreements
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
}
