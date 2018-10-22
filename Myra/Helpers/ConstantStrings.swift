//
//  ConstantStrings.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct PlaceHolders {

    struct Actions {
        static let herding: String = "Frequency, distance and direction livestock will be herded. Identify the high pressure area and/or lower use areas if relevant. Ex. livestock will be herded at least 1 km away from Fish Lake towards the north 3 times per week."
        static let livestockVariables: String = "Type and/or age of livestock to be used to address the issue. If necessary update the grazing schedule to reflect the livestock type. Ex. calves will be 5 months or older before grazing in the riparian area."
        static let salting: String = "Location and timing of salting using an identifiable location and a distance in metres. Ex. remove salt from the NE station (on map) after July 1st."
        static let supplementalFeeding: String = "Type, location and time frame of supplemental feed. Ex. locate protein tub in the south east block in the Pine pasture during the fall rotation."
        static let timing: String = "How livestock use will be timed. Complete the dates for the no grazing window and update the schedule as needed.  Ex. rest the Owl pasture every other year."
        static let other: String = "Describe the action to be taken including what, where and when."
    }

    struct Pasture {
        static let name: String = "Name of pasture (ex. \"crown\" if a single pasture)"
        static let allowableAUMs: String = "Approved maximum AUM allocation for this pasture if applicable"
        static let pld: String = "Percentage of use in this pasture occuring on private land"
        static let graceDays: String = "Acceptable +/- days for livestock movement. Can be tailored by staff in schedule rows."
        static let notes: String = "Pasture specific information (ie. not schedule, plant community or Minister's Issue specific). Examples may include relevant history or topographical considerations."
    }

    struct Schedule {
        static let description: String = "Description of movement of livestock through agreement area. May include WHEN, WHERE and HOW management tools are used to create that flow. May be of particular value when an agreement consists of a single pasture or multiple unfenced pastures."
    }

    struct PlantCommunity {
        static let name: String = "Provincial community name or descriptive"
        static let aspect: String = "Dominant aspect. Ex. SSW or SE"
        static let communityURL: String = "Link to provincial plant community description"
        static let description: String = "Description of the CURRENT plant community. Include a description of the INTENDED plant community (or refer to the provincial description) if actions to establish a plant community are required. As basic or detailed as needed for the purposes required (ex. may be more basic if intended for range readiness assessment than if intended to maintain a plant community). Based on on-site assessments and provincial plant community descriptions."
    }

    struct RangeReadiness {
        static let otherCriteria: String = "Physical conditions that are present when ready for grazing.  Ex. soil is sufficiently dry that livestock use will not result in pugging"
    }

    struct MonitoringAreas {
        static let location: String = "General description of the location (ex. relationship to a known feature or infrastrcture)"
        static let transectAzimuth: String = "The direction from the lat/long point that reflects the position of a transect (if used)"
        static let description: String = "The reason for establishing the monitoring area"
    }

    struct MinistersIssuesAndActions {
        static let details: String = "Accurate description of the issue including WHAT and WHERE the issue is and, if relevant, the TIMING of the issue"
        static let objective: String = "Description of the conditions that will exist when the issue has been resolved (desired state)."
    }

    struct AdditionalRequirements {
        static let name: String = "Name of the requirement (ex. GAR Name)"
        static let description: String = "Name, date, summary (ex. WHA Badger #8-329/#8-330, 2009, attractants and stubble heights)"
        static let linkToDocument: String = "Link to legal document"
    }

    struct ManagementConsiderations {
        let name: String = "Descriptive name ex. short term forage"
        let description: String = "ex. proposed harvesting by company Y in pasture X could provide an opportunity for short term forage"
    }
}

// Tooltip
let tooltipPlanInformationTitle: String = "Tooltip Title"
let tooltipPlanInformationDescription: String = "Create a list with all possible keywords that fit to your product, service or business field. The more the better. So you will get also a lot of keywords which you must pay for only the minimal commandment of 5 cents."

let tooltipPasturesTitle: String = "Tooltip Title"
let tooltipPasturesDescription: String = "Create a list with all possible keywords that fit to your product, service or business field. The more the better. So you will get also a lot of keywords which you must pay for only the minimal commandment of 5 cents."

let tooltipScheduleTitle: String = "Tooltip Title"
let tooltipScheduleDescription: String = "Create a list with all possible keywords that fit to your product, service or business field. The more the better. So you will get also a lot of keywords which you must pay for only the minimal commandment of 5 cents."

let tooltipMinistersIssuesAndActionsTitle: String = "Tooltip Title"
let tooltipMinistersIssuesAndActionsDescription: String = "Create a list with all possible keywords that fit to your product, service or business field. The more the better. So you will get also a lot of keywords which you must pay for only the minimal commandment of 5 cents."

let tooltipPlantCommunitiesTitle: String = "Tooltip Title"
let tooltipPlantCommunitiesDescription: String = "Create a list with all possible keywords that fit to your product, service or business field. The more the better. So you will get also a lot of keywords which you must pay for only the minimal commandment of 5 cents."

// TourTip
let tourTourTitle: String = "Begin Tour"
let tourTourDesc: String = "You can click here to begin this tour again."

let tourCreateNewRupTitle: String = "Create a new plan"
let tourCreateNewRupDesc: String = "Click here to select an agreement and to start a new plan"

let tourSyncTitle: String = "Sync"
let tourSyncDesc: String = "Click here to manually sync agreements and plans when you're Online"

let tourLogoutTitle: String = "Logout"
let tourLogoutDesc: String = "You can logout here"

let tourFiltersTitle: String = "Filter Plans"
let tourFiltersDesc: String = "You can filter your plans here"

let tourlastSyncTitle: String = "Last Sync"
let tourlastSyncDesc: String = "Time elapsed since the last time you manually synced"

let tourPlanCellLatestTitle: String = "Latest Plan"
let tourPlanCellLatestDesc: String = "This is the latest Plan with that range number.\nClick cell to expand."

let tourPlanCellLatestStatusTitle: String = "Current Plan's status"
let tourPlanCellLatestStatusDesc: String = "This is the status of the latest plan for this agreement"

let tourPlanCellVersionsTooltipTitle: String = "Plan Versions"
let tourPlanCellVersionsTooltipDesc: String = "these are different versions of the plan"


let tourPlanCellVersionStatusTooltipTitle: String = "Tooltip"
let tourPlanCellVersionStatusTooltipDesc: String = "Click here to view information about the plan status"

let tourPlanCellVersionViewTooltipTitle: String = "View or Edit plan"
let tourPlanCellVersionViewTooltipDesc: String = "Click here to view or edit plan based on current status"

// Banner
let bannerMinorAmendmentReviewRequiredTitle = "RUP Minor Amendment Review Required"
let bannerMinorAmendmentReviewRequiredDescription = "Review the amendment and make a recommendation to the decision maker of “Amendment Stands”, “Wrongly Made - Stands” or “Wrongly Made - Without Effect”. Do not change the status until the decision maker has responded to your recommendation."

let bannerMandatoryAmendmentReviewRequiredTitle = "RUP Mandatory Amendment Review Required"
let bannerMandatoryAmendmentReviewRequiredDescription = "Review the amendment and make a recommendation to the decision maker of “Amendment Stands”, “Wrongly Made - Stands” or “Wrongly Made - Without Effect”. Do not change the status until the decision maker has responded to your recommendation."
//let bannerMinorAmendment
//let bannerMinorAmendment
//let bannerMinorAmendment
