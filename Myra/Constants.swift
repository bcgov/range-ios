//
//  Constants.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct Constants {
    static let minYear = 1990
    static let maxYear = 2100
    
    struct Defaults {
        static let planId = -1
    }

    struct API {
        static let maxConcurentEndpointRequests = 3
        static let baseURL = URL(string: "http://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/")
//        static let baseURL = URL(string: "http://localhost:8000/v1/")
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let schedulePath = "plan/:id/schedule"
    }
}
