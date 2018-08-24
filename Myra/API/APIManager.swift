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
    case noNetworkConnectivity
    case somethingHappened(message: String)
    case requestFailed(error: Error)
    
    var localizedDescription: String {
        switch self {
        case .somethingHappened(message: let message):
            return message
        case .noNetworkConnectivity:
            return "Not Connected to Internet"
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

    static func getPlanStatus(forPlan plan: RUP, completion: @escaping (_ response: Alamofire.DataResponse<Data>) -> Void) {
        let id = plan.remoteId
//        let endpoint = "http://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/plan/\(id)"
        let planPath = "\(Constants.API.planPath)\(id)"
        guard let endpoint = URL(string: planPath, relativeTo: Constants.API.baseURL!) else {
            return
        }

        Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
             return completion(response)
        }
    }

    static func getReferenceData(completion: @escaping (_ success: Bool) -> Void) {
        
        guard let endpoint = URL(string: Constants.API.referencePath, relativeTo: Constants.API.baseURL!) else {
            return
        }

        Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                RealmManager.shared.clearReferenceData()
                let json = JSON(response.result.value!)
                var newReference = [Object]()
                newReference.append(contentsOf: handleLiveStockType(json: json["LIVESTOCK_TYPE"]))
                newReference.append(contentsOf: handleAgreementType(json: json["AGREEMENT_TYPE"]))
                newReference.append(contentsOf: handleAgreementStatus(json: json["AGREEMENT_STATUS"]))
                newReference.append(contentsOf: handleLivestockIdentifierType(json: json["LIVESTOCK_IDENTIFIER_TYPE"]))
                newReference.append(contentsOf: handleClientType(json:json["CLIENT_TYPE"]))
                newReference.append(contentsOf: handlePlanStatus(json:json["PLAN_STATUS"]))
                newReference.append(contentsOf: handleAgreementExeptionStatus(json: json["AGREEMENT_EXEMPTION_STATUS"]))
                newReference.append(contentsOf: handleMinisterIssueType(json: json["MINISTER_ISSUE_TYPE"]))
                newReference.append(contentsOf: handleMinisterIssueActionType(json: json["MINISTER_ISSUE_ACTION_TYPE"]))
                RUPManager.shared.updateReferenceData(objects: newReference)
                return completion(true)
            }else {
                return completion(false)
            }
        }
    }
    
    static func add(plan: RUP, toAgreement agreementId: String, completion: @escaping (_ plan: [String: Any]?, _ error: Error?) -> ()) {

//        planWithIdPath

        guard let endpoint = URL(string: Constants.API.planPath, relativeTo: Constants.API.baseURL!) else {
            return
        }

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

    static func completeUpload(plan: RUP,toAgreement agreementId: String, completion: @escaping (_ plan: [String: Any]?, _ error: Error?) -> ()) {

        guard let myPlan = DataServices.plan(withLocalId: plan.localId) else {
            return completion(nil, nil)
        }

        let path = "\(Constants.API.planPath)\(myPlan.remoteId)"
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }

        var params: [String:Any]  = [String:Any]()
        params["uploaded"] = true

        var request = URLRequest(url: endpoint)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if let creds = authServices.credentials {
            let token = creds.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = data

        Alamofire.request(request).responseJSON { response in
            APIManager.process(response: response, completion: completion)
        }
        
//        Alamofire.request(endpoint, method: .put, parameters: params, encoding: URLEncoding.httpBody, headers:  headers()).responseJSON { response in
//             APIManager.process(response: response, completion: completion)
//        }

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

    static func add(issue: MinisterIssue, toPlan planId: String, completion: @escaping (_ pasture: [String:Any]?, _ error: Error?) -> ()) {

        let pathKey = ":id"
        let path = Constants.API.issuePath.replacingOccurrences(of: pathKey, with: planId, options: .literal, range: nil)

        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }

        var params = issue.toDictionary()

        params["plan_id"] = planId

        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                APIManager.process(response: response, completion: completion)
        }
    }

    static func add(action: MinisterIssueAction, toIssue issueId: String, inPlan planId: String, completion: @escaping (_ pasture: [String:Any]?, _ error: Error?) -> ()) {
        let issuePathKey = ":issueId?"
        let planPathKey = ":planId?"
        let path1 = Constants.API.actionPath.replacingOccurrences(of: issuePathKey, with: issueId, options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: planPathKey, with: planId, options: .literal, range: nil)


        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }

        let params = action.toDictionary()


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

    static func handleMinisterIssueType(json: JSON) -> [Object] {
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

    static func handleMinisterIssueActionType(json: JSON) -> [Object] {
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

    // Note: UPLOAD ALL DRAFTS/LOCAL CHANGED BEFORE CALLING getAgreements
    // When new agreements are received, old agreements and thir associated data is removed
    static func getAgreements(completion: @escaping (_ rups: [Agreement]?, _ error: APIError?) -> Void, progress: @escaping (_ text: String) -> Void) {
        
        guard let endpoint = URL(string: Constants.API.agreementPath, relativeTo: Constants.API.baseURL!) else {
            return
        }

        // TODO: Update error response type to use APIError (above)
        var agreements: [Agreement] = [Agreement]()
        Alamofire.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                if let error = json["error"].string {
                    let err = APIError.somethingHappened(message: "\(String(describing: error))")
                    return completion(nil, err)
                }
                progress("Processing Agreements")
                deleteAllStoredAgreements()
                DispatchQueue.global(qos: .background).async {
                    for (_,agreementJSON) in json {
                        agreements.append(Agreement(json: agreementJSON))
                    }
                    return completion(agreements, nil)
                }
            } else {
                return completion(agreements, nil)
            }
        }
    }

    static func deleteAllStoredAgreements() {
        let all = RUPManager.shared.getAgreements()
        for element in all {
            for zone in element.zones {
                RealmRequests.deleteObject(zone)
            }

            for rup in element.rups {
                if rup.getStatus() != .LocalDraft {
                    RealmRequests.deleteObject(rup)
                }
            }

            for client in element.clients {
                RealmRequests.deleteObject(client)
            }

            for years in element.rangeUsageYears {
                RealmRequests.deleteObject(years)
            }

            RealmRequests.deleteObject(element)
        }
    }
}

extension APIManager {

    static func sync2(completion: @escaping (_ error: APIError?) -> Void, progress: @escaping (_ text: String) -> Void) {
        print("called Sync 2")
        guard let r = Reachability(), r.connection != .none else {
            progress("Failed while verifying connection")
            completion(APIError.noNetworkConnectivity)
            return
        }

        DataServices.shared.endAutoSyncListener()

        var myError: APIError? = nil

        DataServices.shared.uploadOutboxRangeUsePlans {
            print("Done uploadOutboxRangeUsePlans")
            DataServices.shared.uploadLocalDrafts {
                print("Done uploadLocalDrafts")
                getReferenceData(completion: { (success) in
                    print("Done getReferenceData")
                    if (!success) {
                        progress("Failed while downloading reference data")
                        completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
                    } else {
                        getAgreements(completion: { (agreements, error) in
                            print("Done getAgreements")
                            if let error = error {
                                progress("Sync Failed. \(error.localizedDescription)")
                                myError = error
                                completion(APIError.somethingHappened(message: "Failed while downloading agreements"))
                            } else {
//                                DataServices.shared.updateStatuses(forPlans: RUPManager.shared.getSubmittedPlans()) {
                                    print("Done updateStatuses")
                                    RealmManager.shared.updateLastSyncDate(date: Date(), DownloadedReference: true)
                                    DataServices.shared.beginAutoSyncListener()
                                    completion(myError)
//                                }
                            }
                        }, progress: progress)
                    }
                })
            }
        }
/*
                dispatchGroup.enter()
                getAgreements(completion: { (agreements, error) in
                    progress("Updating plans")
                    if let error = error {
                        progress("Sync Failed. \(error.localizedDescription)")
                        myError = error
                        dispatchGroup.leave()
                        dispatchGroup.suspend()
                        completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
                    } else {
                        dispatchGroup.leave()
                    }
                }, progress: progress)
            }
        }
 */
    }

    static func sync3(completion: @escaping (_ error: APIError?) -> Void, progress: @escaping (_ text: String) -> Void) {
        guard let r = Reachability(), r.connection != .none else {
            progress("Failed while verifying connection")
            completion(APIError.noNetworkConnectivity)
            return
        }
        DataServices.shared.endAutoSyncListener()
        // 1
        DispatchQueue.global(qos: .userInitiated).async {

            var myError: APIError? = nil
            // 2
            let dispatchGroup = DispatchGroup()

            // 3
            dispatchGroup.enter()
            DataServices.shared.uploadOutboxRangeUsePlans {
                progress("Downloading Reference Data")
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            DataServices.shared.uploadLocalDrafts {
                progress("Uploading local drafts")
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            getReferenceData(completion: { (success) in
                progress("Downloading agreements")
                if (!success) {
                    progress("Failed while downloading reference data")
                    dispatchGroup.leave()
                    dispatchGroup.suspend()
                    completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
                } else {
                    dispatchGroup.leave()
                }
            })


            dispatchGroup.enter()
            getAgreements(completion: { (agreements, error) in
                progress("Updating plans")
                if let error = error {
                    progress("Sync Failed. \(error.localizedDescription)")
                    myError = error
                    dispatchGroup.leave()
                    dispatchGroup.suspend()
                    completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
                } else {
                    dispatchGroup.leave()
                }
            }, progress: progress)


            dispatchGroup.enter()
            DataServices.shared.updateStatuses(forPlans: RUPManager.shared.getSubmittedPlans()) {
                dispatchGroup.leave()
            }

            // 5
            dispatchGroup.wait()

            // 6
            DispatchQueue.main.async {
                completion(myError)
            }
        }
    }

    static func sync(completion: @escaping (_ error: APIError?) -> Void, progress: @escaping (_ text: String) -> Void) {
//        sync2(completion: completion, progress: progress)
//        return
        guard let r = Reachability(), r.connection != .none else {
            progress("Failed while verifying connection")
            completion(APIError.noNetworkConnectivity)
            return
        }

        DataServices.shared.endAutoSyncListener()
        
        var myError: APIError? = nil
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        DataServices.shared.uploadOutboxRangeUsePlans {
            progress("Downloading Reference Data")
            dispatchGroup.leave()
        }


        dispatchGroup.enter()
        DataServices.shared.uploadLocalDrafts {
            progress("Uploading local drafts")
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getReferenceData(completion: { (success) in
            progress("Downloading agreements")
            if (!success) {
                progress("Failed while downloading reference data")
                dispatchGroup.leave()
                dispatchGroup.suspend()
                completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
            } else {
                dispatchGroup.leave()
            }
        })


        dispatchGroup.enter()
        getAgreements(completion: { (agreements, error) in
            progress("Updating plans")
            if let error = error {
                progress("Sync Failed. \(error.localizedDescription)")
                myError = error
                dispatchGroup.leave()
                dispatchGroup.suspend()
                completion(APIError.somethingHappened(message: "Failed while downloading reference data"))
            } else {
                dispatchGroup.leave()
            }
        }, progress: progress)


        dispatchGroup.enter()
        DataServices.shared.updateStatuses(forPlans: RUPManager.shared.getSubmittedPlans()) {
            dispatchGroup.leave()
        }


        dispatchGroup.notify(queue: .main) {
            progress("Updating local data")
            RealmManager.shared.updateLastSyncDate(date: Date(), DownloadedReference: true)
            DataServices.shared.beginAutoSyncListener()
            completion(myError)
        }
    }
}
