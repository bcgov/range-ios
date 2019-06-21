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

    struct API {
        struct Dev {
            static let baseURL = URL(string: "https://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/")!

        }
        struct Test {
            static let baseURL = URL(string: "https://api-range-myra-test.pathfinder.gov.bc.ca/api/v1/")!

        }

        struct Prod {
            static let baseURL = URL(string: "https://api-range-myra-prod.pathfinder.gov.bc.ca/api/v1/")!

        }
        
        static let maxConcurentEndpointRequests = 3
        
        static var baseURL: URL {
            switch SettingsManager.shared.getCurrentEnvironment() {
            case .Dev:
                return Constants.API.Test.baseURL
            case .Prod:
                return Constants.API.Prod.baseURL
            }
        }
        
        static let versionPath = "version"
        static let userInfoPath = "user/me"
        static let referencePath = "reference/"
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let plantCommunityPath = "plan/:planId/pasture/:pastureId/plant-community"
        static let plantCommunityActionPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/action"
        static let indicatorPlantPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/indicator-plant"
        static let monitoringAreaPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/monitoring-area"
        static let invasivePlantsPath = "plan/:planId/invasive-plant-checklist"
        static let agreementPath = "agreement/"
        static let schedulePath = "plan/:id/schedule"
        static let issuePath = "plan/:id/issue"
        static let actionPath = "plan/:planId?/issue/:issueId?/action"
        static let additionalRequirement = "plan/:planId/additional-requirement"
        static let managementConsideration = "plan/:planId/management-consideration"
        static let feedbackPath = "feedback/"
    }

    struct Alerts {
        struct UserInfoUpdate {
            struct Success {
                static let title = "Done"
                static let message = "Your information was successfully updated."
            }

            struct Fail {
                static let title = "There was an error"
                static let message = "We couldn't update your name at this time. we will ask you again later."
            }
        }
    }
}
