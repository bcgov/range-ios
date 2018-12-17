//
//  API.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-14.
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

class API {

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

    /*************************************************************************************************************/

    // MARK: Put Post and Get requests
    static func put(endpoint: URL, params: [String:Any], completion: @escaping (_ response: DataResponse<Any>? ) -> Void) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if let creds = API.authServices.credentials {
            let token = creds.accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = data


        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.shared.show(message: "Request Time Out")
                return completion(nil)
            }
        }

        Alamofire.request(request).responseJSON { response in
            completed = true
            if timedOut {return}
            return completion(response)
        }
    }

    static func post(endpoint: URL, params: [String:Any], completion: @escaping (_ response: [String:Any]?) -> Void) {
        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.shared.show(message: "Request Time Out")
                return completion(nil)
            }
        }
        
        // Request
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers()).responseJSON { response in
            completed = true
            if timedOut {return}
            API.process(response: response, completion: { (processedResponse, error) in
                guard let processedResponse = processedResponse, error == nil else {
                    print("POST call rejected:")
                    print("Endpoint: \(endpoint)")
                    print("Error: \(error?.localizedDescription ?? "Unknown")")
                    return completion(nil)
                }
                return completion(processedResponse)
            })
        }
    }

    static func get(endpoint: URL, completion: @escaping (_ response: JSON?) -> Void) {
        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.shared.show(message: "Request Time Out")
                return completion(nil)
            }
        }
        Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
            completed = true
            if timedOut {return}
            if response.result.description == "SUCCESS", let value = response.result.value {
                let json = JSON(value)
                if let error = json["error"].string {
                    print("GET call rejected:")
                    print("Endpoint: \(endpoint)")
                    print("Error: \(error)")
                    return completion(nil)
                } else {
                    // Success
                    return completion(json)
                }
            } else {
                print("GET call failed:")
                print("Endpoint: \(endpoint)")
                return completion(nil)
            }
        }
    }

    private static func process(response: Alamofire.DataResponse<Any>, completion: APIRequestCompleted) {
        switch response.result {
        case .success(let value):
            if let json = value as? [String: Any], let status = json["success"] as? Bool, status == false {
                let err = APIError.somethingHappened(message: "Failed while processing server response")
                // let err = APIError.somethingHappened(message: "\(String(describing: json["error"] as? String))")
                print("Request Failed, error = \(err.localizedDescription)")
                print(response.value)
                return completion(nil, err)
            }

            return completion(value as? [String: Any], nil)
        case .failure(let error):
            return completion(nil, APIError.requestFailed(error: error))
        }
    }
    /*************************************************************************************************************/

    // MARK: API Calls

    // MARK: User Info
    static func getUserInfo(completion: @escaping(_ userInfo: UserInfo?) -> Void) {
        guard let endpoint = URL(string: Constants.API.userInfoPath, relativeTo: Constants.API.baseURL!) else {
            return completion(nil)
        }

        API.get(endpoint: endpoint) { (jsonResponse) in
            guard let infoJSON = jsonResponse else { return completion(nil) }
            if let isNull = infoJSON.null {
                return completion(nil)
            } else {
                return completion(UserInfo(from: infoJSON))
            }
        }
    }

    static func updateUserInfo(firstName: String, lastName: String, completion: @escaping (_ success: Bool) -> Void) {
        // TODO: Change to appropriate Endpoint when available
        guard let endpoint = URL(string: Constants.API.userInfoPath, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }
        var params: [String:Any]  = [String:Any]()
        params["givenName"] = firstName
        params["familyName"] = lastName
        API.put(endpoint: endpoint, params: params) { (response) in
            if let rsp = response, !rsp.result.isFailure {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }

    // MARK: Agreement
    static func getAgreements(completion: @escaping (_ success: Bool) -> Void) {
        guard let endpoint = URL(string: Constants.API.agreementPath, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }

        API.get(endpoint: endpoint) { (agreementsJSON) in
            guard let agreementsJSON = agreementsJSON else {return completion(false)}
            var agreements: [Agreement] = [Agreement]()
            DispatchQueue.global(qos: .background).async {
                // Deleted current agreements
                RealmManager.shared.deleteAllStoredAgreements()
                for (_,agreementJSON) in agreementsJSON {
                    // This also saves the object
                    agreements.append(Agreement(json: agreementJSON))
                }
                return completion(true)
            }
        }
    }

    // MARK: Reference
    static func getReferenceData(completion: @escaping (_ referenceObjects: [Object]?) -> Void) {
        guard let endpoint = URL(string: Constants.API.referencePath, relativeTo: Constants.API.baseURL!) else {
            return completion(nil)
        }

        API.get(endpoint: endpoint) { (referenceJSON) in
            guard let referenceJSON = referenceJSON else {return completion(nil)}
            return completion(Reference.shared.handleReference(json: referenceJSON))
        }
    }

    // MARK: Plan
    static func getPlan(withRemoteId id: Int, completion: @escaping (_ plan: RUP?) -> Void) {
        let planPath = "\(Constants.API.planPath)\(id)"
        guard let endpoint = URL(string: planPath, relativeTo: Constants.API.baseURL!) else {
            return completion(nil)
        }

        API.get(endpoint: endpoint) { (planJSON) in
            guard let planJSON = planJSON else {return completion(nil)}
            let plan = RUP()
            plan.populateFrom(json: planJSON)
            return completion(plan)
        }
    }

    static func refetch(plan: RUP, completion: @escaping (_ success: Bool) -> Void) {
        API.getPlan(withRemoteId: plan.remoteId) { (plan) in
            guard let new = plan, let old = RealmManager.shared.plan(withRemoteId: new.remoteId), let agreement = RealmManager.shared.agreement(withAgreementId: old.agreementId) else {
                Banner.shared.show(message: "ERROR while re-fetching a plan")
                return completion(false)
            }
            // delete existing plan.
            RealmRequests.deleteObject(old)
            // set client and range usage years from agreement
            new.setFrom(agreement: agreement)
            // add plan to agreement
            agreement.add(plan: new)
            // save plan object
            RealmRequests.saveObject(object: new)
            return completion(true)
        }
    }

    static func setStatus(for plan: RUP, completion: @escaping (_ success: Bool) -> Void) {
        let id = plan.remoteId
        let planPath = "\(Constants.API.planPath)\(id)/status"

        guard let endpoint = URL(string: planPath, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }

        var params: [String:Any]  = [String:Any]()
        params["statusId"] = plan.statusId
        API.put(endpoint: endpoint, params: params) { (response) in
            if let rsp = response, !rsp.result.isFailure  {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }

    static func getStatus(for plan: RUP, completion: @escaping (_ success: Bool) -> Void) {
        API.getPlan(withRemoteId: plan.remoteId) { (downloadedPlan) in
            guard let downloadedPlan = downloadedPlan else {
                Banner.shared.show(message: "ERROR while updating a plan status")
                return completion(false)
            }
            plan.updateStatusId(newID: downloadedPlan.statusId)
            return completion(true)
        }
    }

    static func upload(statusesFor plans: [RUP], completion: @escaping (_ success: Bool) -> Void) {
        let group = DispatchGroup()
        var hadFails = false
        for plan in plans {
            let localId = plan.localId
            group.enter()

            guard let myPlan = RealmManager.shared.plan(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            API.setStatus(for: myPlan) { (success) in
                if success, let refetchPlan = RealmManager.shared.plan(withLocalId: localId) {
                    refetchPlan.setShouldUpdateRemoteStatus(should: false)
                } else {
                    Banner.shared.show(message: "ERROR while updating a plan status")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(!hadFails)
        }
    }

    static func completeUpload(for plan: RUP, completion: @escaping (_ success: Bool) -> Void) {
        guard let myPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        let path = "\(Constants.API.planPath)\(myPlan.remoteId)"
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }
        var params: [String:Any]  = [String:Any]()
        params["uploaded"] = true
        API.put(endpoint: endpoint, params: params) { (response) in
            if let rsp = response, !rsp.result.isFailure {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }

    static func upload(plans: [RUP], completion: @escaping (_ success: Bool) -> ()) {
        let group = DispatchGroup()
        var hadFails: Bool = false
        for plan in plans {
            let localId = plan.localId
            group.enter()
            guard let myPlan = RealmManager.shared.plan(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            API.upload(plan: myPlan) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a plan")
                    hadFails = true
                }
                group.leave() 
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    static func upload(plan: RUP, completion: @escaping (_ success: Bool) -> ()) {

        guard let endpoint = URL(string: Constants.API.planPath, relativeTo: Constants.API.baseURL!), let currentPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {
            return completion(false)
        }

        var params = currentPlan.toDictionary()
        let localId = plan.localId
        params["agreementId"] = currentPlan.agreementId

        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int else {
                return completion(false)
            }

            guard let refetchedPlan = RealmManager.shared.plan(withLocalId: localId) else {
                return completion(false)
            }
            refetchedPlan.setRemoteId(id: remoteId)
            API.uploadComponents(forPlan: refetchedPlan, completion: { (success) in
                if !success {
                    Banner.shared.show(message: "Error while uploading plan components")
                }
                return completion(success)
            })
        }
    }

    static func uploadComponents(forPlan plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchPlan = RealmManager.shared.plan(withLocalId: plan.localId) else { return completion(false) }
        API.upload(pasturesIn: refetchPlan) { (uploadedPastures) in
            if uploadedPastures {
                API.upload(schedulesIn: refetchPlan, completion: { (uploadedSchedules) in
                    if uploadedSchedules {
                        API.upload(ministersIssuesIn: refetchPlan, completion: { (uploadedMinistersIssues) in
                            if uploadedMinistersIssues {
                                API.upload(invasivePlantsIn: refetchPlan, completion: { (uploadedInvasivePlants) in
                                    if uploadedInvasivePlants {
                                        API.upload(managementConsiderations: refetchPlan, completion: { (uploadedManagementConsideration) in
                                            if uploadedManagementConsideration {
                                                API.upload(additionalRequirements: refetchPlan, completion: { (uploadedAdditionalRequirements) in
                                                    if uploadedAdditionalRequirements {
                                                        API.completeUpload(for: refetchPlan, completion: { (completed) in
                                                            if completed {
                                                                API.refetch(plan: refetchPlan, completion: { (done) in
                                                                    return completion(done)
                                                                })
                                                            } else {
                                                                return completion(false)
                                                            }
                                                        })
                                                    } else {
                                                         return completion(false)
                                                    }
                                                })
                                            } else {
                                                 return completion(false)
                                            }
                                        })
                                    } else {
                                        return completion(false)
                                    }
                                })
                            } else {
                                return completion(false)
                            }
                        })
                    } else {
                        return completion(false)
                    }
                })
            } else {
                return completion(false)
            }
        }
    }

    // MARK: Invasive Plants
    static func upload(invasivePlants: InvasivePlants, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":planId"
        let path = Constants.API.invasivePlantsPath.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        var params = invasivePlants.toDictionary()
        let localId = invasivePlants.localId
        params["plan_id"] = planRemoteId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedInvasivePlants = RealmManager.shared.invasivePlants(withLocalId: localId) else {
                return completion(false)
            }
            refetchedInvasivePlants.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(invasivePlantsIn plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        if let invasivePlantsObject = refetchedPlan.invasivePlants.first {
            upload(invasivePlants: invasivePlantsObject, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading Invasive Plants")
                    return completion(false)
                }
                return completion(true)
            }
        } else {
            return completion(true)
        }
    }
    // MARK: Management Considerations
    static func upload(managementConsideration: ManagementConsideration, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":planId"
        let path = Constants.API.managementConsideration.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        var params = managementConsideration.toDictionary()
        let localId = managementConsideration.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedIObjects = RealmManager.shared.managementConsideration(withLocalId: localId) else {
                return completion(false)
            }
            refetchedIObjects.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(managementConsiderations plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for managementConsideration in refetchedPlan.managementConsiderations {
            let localId = managementConsideration.localId
            group.enter()
            guard let myManagementConsideration =  RealmManager.shared.managementConsideration(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(managementConsideration: myManagementConsideration, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a Management Consideration")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }
    // MARK: Additional Requirements
    static func upload(additionalRequirement: AdditionalRequirement, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":planId"
        let path = Constants.API.additionalRequirement.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        var params = additionalRequirement.toDictionary()
        let localId = additionalRequirement.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedIObjects = RealmManager.shared.additionalRequirement(withLocalId: localId) else {
                return completion(false)
            }
            refetchedIObjects.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(additionalRequirements plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for additionalRequirement in refetchedPlan.additionalRequirements {
            let localId = additionalRequirement.localId
            group.enter()
            guard let myAdditionalRequirement =  RealmManager.shared.additionalRequirement(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(additionalRequirement: myAdditionalRequirement, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading an Additional Consideration")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }
    // MARK: Pasture
    static func upload(pasture: Pasture, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":id"
        let path = Constants.API.pasturePath.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        var params = pasture.toDictionary()
        let localId = pasture.localId
        params["plan_id"] = planRemoteId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedPasture = RealmManager.shared.pasture(withLocalId: localId) else {
                return completion(false)
            }

            refetchedPasture.setRemoteId(id: remoteId)
            upload(plantCommunitiesIn: refetchedPasture, forPlanRemoteId: planRemoteId, completion: { (success) in
                 return completion(success)
            })
        }
    }

    static func upload(pasturesIn plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for pasture in refetchedPlan.pastures {
            let localId = pasture.localId
            group.enter()
            guard let myPasture =  RealmManager.shared.pasture(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(pasture: myPasture, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a pasture")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Plant Community
    static func upload(plantCommunity: PlantCommunity, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let planIdKey = ":planId"
        let pastureIdKey = ":pastureId"
        let path1 = Constants.API.plantCommunityPath.replacingOccurrences(of: planIdKey, with: "\(planRemoteId)", options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: pastureIdKey, with: "\(pastureRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        let params = plantCommunity.toDictionary()
        let localId = plantCommunity.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedObject = RealmManager.shared.plantCommunity(withLocalId: localId) else {
                return completion(false)
            }
            refetchedObject.setRemoteId(id: remoteId)
            upload(monitoringAreasIn: refetchedObject, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId, completion: { (monitoringAreaSuccess) in
                if monitoringAreaSuccess {
                    upload(indicatorPlantsIn: refetchedObject, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId, completion: { (indicatorPlantsSuccess) in
                        if indicatorPlantsSuccess {
                            upload(plantCommunityActionsIn: refetchedObject, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId, completion: { (success) in
                                return completion(success)
                            })
                        } else {
                            return completion(false)
                        }
                    })
                } else {
                    return completion(false)
                }
            })

        }
    }

    static func upload(plantCommunitiesIn pasture: Pasture, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedObject = RealmManager.shared.pasture(withLocalId: pasture.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for plantCommunity in refetchedObject.plantCommunities {
            let localId = plantCommunity.localId
            group.enter()

            guard let myPlantCommunity = RealmManager.shared.plantCommunity(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(plantCommunity: myPlantCommunity, forPastureRemoteId: refetchedObject.remoteId, forPlanRemoteId: planRemoteId) { (success) in
                    if !success {
                        Banner.shared.show(message: "ERROR while uploading a plant community")
                        hadFails = true
                    }
                    group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Monitoring Areas
    static func upload(monitoringArea: MonitoringArea, forPlantCommunityRemoteId plantCommunityRemoteId: Int, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let planIdKey = ":planId"
        let pastureIdKey = ":pastureId"
        let plantCommunityIdKey = ":plantCommunityId"
        let path2 = Constants.API.monitoringAreaPath.replacingOccurrences(of: planIdKey, with: "\(planRemoteId)", options: .literal, range: nil)
        let path1 = path2.replacingOccurrences(of: pastureIdKey, with: "\(pastureRemoteId)", options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: plantCommunityIdKey, with: "\(plantCommunityRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        let params = monitoringArea.toDictionary()
        let localId = monitoringArea.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedObject = RealmManager.shared.monitoringArea(withLocalId: localId) else {
                return completion(false)
            }
            refetchedObject.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(monitoringAreasIn plantCommunity: PlantCommunity, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedObject = RealmManager.shared.plantCommunity(withLocalId: plantCommunity.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for monitoringArea in refetchedObject.monitoringAreas {
            let localId = monitoringArea.localId
            group.enter()

            guard let myMonitoringArea = RealmManager.shared.monitoringArea(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(monitoringArea: myMonitoringArea, forPlantCommunityRemoteId: refetchedObject.remoteId, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a monitoring area")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Indicator Plants
    static func upload(indicatorPlant: IndicatorPlant, forPlantCommunityRemoteId plantCommunityRemoteId: Int, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let planIdKey = ":planId"
        let pastureIdKey = ":pastureId"
        let plantCommunityIdKey = ":plantCommunityId"
        let path2 = Constants.API.indicatorPlantPath.replacingOccurrences(of: planIdKey, with: "\(planRemoteId)", options: .literal, range: nil)
        let path1 = path2.replacingOccurrences(of: pastureIdKey, with: "\(pastureRemoteId)", options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: plantCommunityIdKey, with: "\(plantCommunityRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        let params = indicatorPlant.toDictionary()
        let localId = indicatorPlant.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedObject = RealmManager.shared.indicatorPlant(withLocalId: localId) else {
                return completion(false)
            }
            refetchedObject.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(indicatorPlantsIn plantCommunity: PlantCommunity, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedObject = RealmManager.shared.plantCommunity(withLocalId: plantCommunity.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for indicatorPlant in refetchedObject.getIndicatorPlants() {
            let localId = indicatorPlant.localId
            group.enter()

            guard let myIndicatorPlant = RealmManager.shared.indicatorPlant(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(indicatorPlant: myIndicatorPlant, forPlantCommunityRemoteId: refetchedObject.remoteId, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading an Indicator Plant")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Pasture Actions
    static func upload(plantCommunityAction: PastureAction, forPlantCommunityRemoteId plantCommunityRemoteId: Int, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let planIdKey = ":planId"
        let pastureIdKey = ":pastureId"
        let plantCommunityIdKey = ":plantCommunityId"
        let path2 = Constants.API.plantCommunityActionPath.replacingOccurrences(of: planIdKey, with: "\(planRemoteId)", options: .literal, range: nil)
        let path1 = path2.replacingOccurrences(of: pastureIdKey, with: "\(pastureRemoteId)", options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: plantCommunityIdKey, with: "\(plantCommunityRemoteId)", options: .literal, range: nil)

        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }

        let params = plantCommunityAction.toDictionary()
        let localId = plantCommunityAction.localId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedObject = RealmManager.shared.pastureAction(withLocalId: localId) else {
                return completion(false)
            }
            refetchedObject.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(plantCommunityActionsIn plantCommunity: PlantCommunity, forPastureRemoteId pastureRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedObject = RealmManager.shared.plantCommunity(withLocalId: plantCommunity.localId) else {return completion(false)}
        let group = DispatchGroup()
        var hadFails = false
        for action in refetchedObject.pastureActions {
            let localId = action.localId
            group.enter()

            guard let myAction = RealmManager.shared.pastureAction(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(plantCommunityAction: myAction, forPlantCommunityRemoteId: refetchedObject.remoteId, forPastureRemoteId: pastureRemoteId, forPlanRemoteId: planRemoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading an Plant Community Action")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Schedule
    static func upload(schedule: Schedule, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":id"
        let path = Constants.API.schedulePath.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)
        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }
        var params = schedule.toDictionary()
        let localId = schedule.localId
        params["plan_id"] = planRemoteId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedSchedule = RealmManager.shared.schedule(withLocalId: localId) else {
                return completion(false)
            }
            refetchedSchedule.setRemoteId(id: remoteId)
            return completion(true)
        }
    }

    static func upload(schedulesIn plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        if refetchedPlan.schedules.count == 0 {return completion(true)}
        let group = DispatchGroup()
        var hadFails = false
        for schedule in refetchedPlan.schedules {
            let localId = schedule.localId
             group.enter()
            
            guard let mySchedule = RealmManager.shared.schedule(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(schedule: mySchedule, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a schedule")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Ministers issues
    static func upload(ministersIssue: MinisterIssue, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let pathKey = ":id"
        let path = Constants.API.issuePath.replacingOccurrences(of: pathKey, with: "\(planRemoteId)", options: .literal, range: nil)

        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }

        var params = ministersIssue.toDictionary()
        let localId = ministersIssue.localId
        params["plan_id"] = planRemoteId
        API.post(endpoint: endpoint, params: params) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedIssue = RealmManager.shared.ministersIssue(withLocalId: localId) else {
                return completion(false)
            }
            refetchedIssue.setRemoteId(id: remoteId)
            // upload action
            upload(actionsIn: refetchedIssue, forPlanRemoteId: planRemoteId, completion: { (success) in
                return completion(success)
            })
        }
    }

    static func upload(ministersIssuesIn plan: RUP, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchedPlan = RealmManager.shared.plan(withLocalId: plan.localId) else {return completion(false)}
        if refetchedPlan.ministerIssues.count == 0 {return completion(true)}
        let group = DispatchGroup()
        var hadFails = false
        for issue in refetchedPlan.ministerIssues {
            let localId = issue.localId
            group.enter()
            guard let myIssue = RealmManager.shared.ministersIssue(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(ministersIssue: myIssue, forPlanRemoteId: refetchedPlan.remoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a ministers issue")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Ministers issue action
    static func upload(ministerIssueAction: MinisterIssueAction, forIssueRemoteId issueRemoteId: Int, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        let issuePathKey = ":issueId?"
        let planPathKey = ":planId?"
        let path1 = Constants.API.actionPath.replacingOccurrences(of: issuePathKey, with: "\(issueRemoteId)", options: .literal, range: nil)
        let path = path1.replacingOccurrences(of: planPathKey, with: "\(planRemoteId)", options: .literal, range: nil)

        guard let endpoint = URL(string: path, relativeTo: Constants.API.baseURL!) else {
            return
        }
        let localId = ministerIssueAction.localId
        API.post(endpoint: endpoint, params: ministerIssueAction.toDictionary()) { (response) in
            guard let response = response, let remoteId = response["id"] as? Int, let refetchedAction = RealmManager.shared.ministersIssueAction(withLocalId: localId) else {
                return completion(false)
            }
            refetchedAction.setRemoteId(id: remoteId)
            return completion(true)
        }

    }

    static func upload(actionsIn ministerIssue: MinisterIssue, forPlanRemoteId planRemoteId: Int, completion: @escaping (_ success: Bool) -> ()) {
        guard let refetchIssue = RealmManager.shared.ministersIssue(withLocalId: ministerIssue.localId) else {return completion(false)}
        if refetchIssue.actions.count == 0 {return completion(true)}
        let group = DispatchGroup()
        var hadFails = false
        for action in refetchIssue.actions {
            let localId = action.localId
            group.enter()
            guard let myAction = RealmManager.shared.ministersIssueAction(withLocalId: localId) else {
                hadFails = true
                group.leave()
                return
            }

            upload(ministerIssueAction: myAction, forIssueRemoteId: refetchIssue.remoteId, forPlanRemoteId: planRemoteId) { (success) in
                if !success {
                    Banner.shared.show(message: "ERROR while uploading a ministers issue action")
                    hadFails = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }

    // MARK: Sync
    static func sync(completion: @escaping (_ success: Bool) -> Void, progress: @escaping (_ text: String) -> Void) {
        guard let r = Reachability(), r.connection != .none else {
            progress("Failed while verifying connection")
            return completion(false)
        }

        AutoSync.shared.endListener()

        API.uploadContent(completion: { (uploaded) in
            if uploaded {
                progress("Downloading Reference Data")
                API.getReferenceData { (reference) in
                    if let referenceObjects = reference {
                        progress("Storing Reference Data")
                        Reference.shared.clearReferenceData()
                        for object in referenceObjects {
                            RealmRequests.saveObject(object: object)
                        }
                        progress("Downloading agreements")
                        API.getAgreements { (success) in
                            if success {
                                progress("wrapping up")
                                // Done
                                RUPManager.shared.fixUnlinkedPlans()
                                RealmManager.shared.updateLastSyncDate(date: Date(), DownloadedReference: true)
                                DispatchQueue.main.async {
                                    AutoSync.shared.beginListener()
                                    return completion(true)
                                }
                            } else {
                                // fail
                                return completion(false)
                            }
                        }
                    } else {
                        // fail
                        return completion(false)
                    }
                }
            } else {
                // fail
                return completion(false)
            }
        }, progress: progress)
    }

    static func uploadContent(completion: @escaping (_ success: Bool) -> Void, progress: @escaping (_ text: String) -> Void) {
        let dispatchGroup = DispatchGroup()

        // Update remote statuses
        dispatchGroup.enter()
        let plansWithUpdatesStatuses = RUPManager.shared.getRUPsWithUpdatedLocalStatus()
        progress("Updating plan statuses")
        API.upload(statusesFor: plansWithUpdatesStatuses) { (success) in
            if success {
                dispatchGroup.leave()
            } else {
                // Handle fail
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main) {
                    return completion(false)
                }
            }
        }

        // Upload outbox plans
        dispatchGroup.enter()
        let outboxPlans = RUPManager.shared.getOutboxRups()
        progress("Uploading outbox plans")
        API.upload(plans: outboxPlans) { (success) in
            if success {
                dispatchGroup.leave()
            } else {
                // Handle fail
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main) {
                    return completion(false)
                }
            }
        }

        dispatchGroup.enter()
        let draftPlans = RUPManager.shared.getDraftRupsValidForUpload()
        progress("Uploading local drafts")
        API.upload(plans: draftPlans) { (success) in
            if success {
                dispatchGroup.leave()
            } else {
                // Handle fail
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main) {
                    return completion(false)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            return completion(true)
        }
    }
}
