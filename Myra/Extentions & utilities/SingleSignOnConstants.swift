//
//  SingleSignOnConstants.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct SingleSignOnConstants {
    struct SSO {
        static let baseUrl = URL(string: "https://dev-sso.pathfinder.gov.bc.ca")!
        static let redirectUri = "http://web-range-myra-dev.pathfinder.gov.bc.ca/login"
        static let clientId = "range-test"
        static let realmName = "mobile"
        static let idpHint = ""
    }
}
