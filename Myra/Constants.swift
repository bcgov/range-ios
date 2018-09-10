//
//  Constants.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Defaults {
        static let planId = -1
    }

    // dev

    struct API {
        static let maxConcurentEndpointRequests = 3
        static let baseURL = URL(string: "https://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/")
//        static let baseURL = URL(string:"https://web-range-myra-test.pathfinder.gov.bc.ca/api/v1/")
//        static let baseURL = URL(string: "http://10.10.10.180:8000/api/v1/")
        static let referencePath = "reference/"
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let agreementPath = "agreement/"
        static let schedulePath = "plan/:id/schedule"
        static let issuePath = "plan/:id/issue"
        static let actionPath = "plan/:planId?/issue/:issueId?/action"
    }
    
    struct SSO {
        static let baseUrl = URL(string: "https://dev-sso.pathfinder.gov.bc.ca")!
        static let redirectUri = "myra-ios://client"
        static let clientId = "range-test"
        static let realmName = "mobile"
        static let idpHint = ""
    }



    // test
    /*
    struct API {
        static let maxConcurentEndpointRequests = 3
        static let baseURL = URL(string: "https://api-range-myra-test.pathfinder.gov.bc.ca/api/v1/")
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let referencePath = "reference/"
        static let agreementPath = "agreement/"
        static let schedulePath = "plan/:id/schedule"
        static let issuePath = "plan/:id/issue"
        static let actionPath = "plan/:planId?/issue/:issueId?/action"
    }

    struct SSO {
        static let baseUrl = URL(string: "https://dev-sso.pathfinder.gov.bc.ca")!
        static let redirectUri = "myra-ios://client"
        static let clientId = "range-test"
        static let realmName = "mobile"
        static let idpHint = ""
    }
    */
}
