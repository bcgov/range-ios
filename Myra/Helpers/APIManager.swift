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

class APIManager {

    static let baseURL = "http://api-range-myra-dev.pathfinder.gov.bc.ca/v1"
    static let agreementEndpoint = "\(baseURL)/agreement"
    static let reference = "\(baseURL)/reference"

    static func headers() -> HTTPHeaders {
        let h = ["Content-Type" : "application/json"]
        return h
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

    static func getDummyRUPs(completion: @escaping (_ success: Bool,_ rups: [RUP]?) -> Void) {
        Alamofire.request(agreementEndpoint, method: .get, encoding: JSONEncoding.default, headers: headers()).responseData { (response) in
            if response.result.description == "SUCCESS" {
                let json = JSON(response.result.value!)
                var rups: [RUP] = [RUP]()
                if json["error"].dictionary != nil {
                    return completion(false, nil)
                }

                for (_,rupJSON) in json {
                    rups.append( handleAgreementJSON(rupJSON: rupJSON))
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
        var id = -1
        var planStartDate: Date?
        var rangeName: String = ""
        var agreementStartDate: Date?
        var updatedAt: Date?
        var exemptionStatus: Bool = false
        var agreementId: String = ""
        var planEndDate: Date?
        var agreementEndDate: Date?
        var notes: String = ""

        if let s = rupJSON["status"].string {
            status = s
        }
        if let i = rupJSON["id"].int {
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

        return rup
    }

}
