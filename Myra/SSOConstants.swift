//
//  SSOConstants.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-03-19.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

struct SSO {
    struct Dev {
        static let baseUrl = URL(string: "https://sso-dev.pathfinder.gov.bc.ca")!
    }
    struct Test {
        static let baseUrl = URL(string: "https://sso-test.pathfinder.gov.bc.ca")!
    }
    struct Prod {
        static let baseUrl = URL(string: "https://sso.pathfinder.gov.bc.ca")!
    }
    
    static var baseUrl: URL {
        switch SettingsManager.shared.getCurrentEnvironment() {
        case .Dev:
            return SSO.Test.baseUrl
        case .Prod:
            return SSO.Prod.baseUrl
        }
    }
    static let redirectUri = "myra-ios://client"
    static let clientId = "myrangebc"
    static let realmName = "range"
    static let idpHint = "idir"
}
