//
//  ConstantStrings.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct Messages {
    struct AutoSync {
        static let manualSyncRequired = "Please Synchronize manually: Authentication is required"
    }
}

struct TourMessages {

    struct Home {

        struct createNewPlan {
            static let title = "Create A New Range Use Plan"
            static let body = "Tap here to view all RUP’s that have not yet moved to the new digital RUP and "
        }

        struct filterRups {
            static let title = "Filter RUPs"
            static let body = "Use this section to filter RUPs in your work queue and help you prioritize."
        }

        struct latestPlan {
            static let title = "Latest Plan"
            static let body = "Each row on the home screen represents a RUP. Tap the row to expand to view all versions of the plan and edit initial plans and amendments."
        }

        struct planStatus {
            static let title = "Plan Status"
            static let body = "This section shows the plan’s current status"
        }

        struct editViewPlan {
            static let title = "Edit and View RUPs"
            static let body = "Tap this button to view or edit a RUP depending on its status."
        }
    }

    struct Schedule {

        struct createEntry{
            static let title = "Create A New Range Use Plan"
            static let body = "Create your first schedule row by tapping this button. Pastures you entered previously will already be populated so you can quickly build out your schedule. Rows you enter will automatically count against your total allowable AUMs."
        }

        struct overflowMenu {
            static let title = "Create A New Range Use Plan"
            static let body = "Use this overflow menu throughout the myrangebc app to delete and duplicate items and rows. This can help make schedule creation even faster."
        }
    }
}

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
        static let notes: String = "Pasture specific information (i.e. not schedule, plant community or Minister's Issue specific). Examples may include relevant history or topographical considerations."
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
        static let name: String = "Descriptive name ex. short term forage"
        static let description: String = "ex. proposed harvesting by company Y in pasture X could provide an opportunity for short term forage"
    }
}

struct InfoTips {

    static let usage = "Authorized usaged entered in FTA. If incorrect or incomplete, update FTA and wait for daily sync of myra with FTA"
    static let basicInformation = "Agreement specifics from FTA (including usage) and plan specifics entered by staff. If there is agreement information that is incorrect, update FTA and wait until next FTA sync (daily)."

    static let rangeName = "Each agreement needs to have a common name (descriptive or nickname) to easily distinguish between ranges when an agreement holder has more than one. If the agreement holder has only one agreement the range name might be simply “crown.”"

    static let pastures = "FRPA section 33 indicates that an RUP for grazing must include both a map showing pastures and a schedule having livestock class, number and period of use for each pasture.\n\nWhere an agreement area is not subdivided into pastures there is a single pastures whose boundary matches that of the agreement.\n\nPastures may be one of two types\n1. Closed: those having the entire boundary accurately defined by physical barriers (ex.fence or NRB)\n2. Open: those not having the entire boundary accurately defined by physical barriers (i.e. at least a portion of the boundary reflects an approximate transition between one pasture and the next)\n\nYou might choose to select a ‘grace days’ value appropriate for the pasture type."

    static let privateLandDeduction = "Percentage of total forage grazed from this pasture attributed to private land."

    static let allowableAUMs = "Approved maximum AUM allocation for this pasture. The default is “not set” to indicate that there is not a approved AUM allocation for the pastures. Overwrite this value if there is an approved AUM allocation."

    static let plantCommunityActions = "RPPR section 13(1) allows the minister to specify actions to establish or maintain a described plant community. Actions are to be determined by staff and accepted by the decision maker before sending the RUP or amendment to the agreement holder. In some situations it may be appropriate to discuss the specifics of the plant community with the agreement holder before determining the actions and seeking acceptance from the decision maker."

    static let criteria = "RPPR section 13 allows the minister to specify range readiness and stubble height criteria that are either described in the Schedule or consistent with objectives set by government. Readiness defaults for species in this app are consistent with the schedule."

    static let browseUsage = "RPPR section 29 indicates that unless otherwise specified in the RUP acceptable average browse is 25% of current annual grown."

    static let monitoringAreas = "Every plant community must have at least one monitoring area.\n\nRather than an extensive sampling approach to determine an average criteria measurement (ex. leaf stage or stubble height), monitoring areas are selected in locations that reflect an average condition within the plant community for the purpose selected. The location of monitoring areas should be carefully selected based on the purpose(s) of the monitoring area. An appropriate location for sampling for average readiness criteria may not be appropriate for sampling for average stubble height.\n\nRecognizing that management occurs primarily at the pasture level, where a pasture includes multiple plant communities you will likely want to select monitoring areas within the plant communities that are most relevant for the various criteria included."

    static let monitoringAreaPurpose = "Each monitoring area must be selected carefully based on the purpose it is needed.\n\nRange Readiness: date, average plant growth or text statement that identifies when range is ready to be grazed\nStubble Height: the average height of plants remaining after grazing\n\nShrub Use: average browse use level of current annual growth\n\nKey Area: a relatively small portion of a range selected because of its location, use or grazing values as a monitoring point for grazing use. It is assumed that, if properly selected, key areas will reflect the overall acceptability of current grazing management over the range.\n\nOther: text description of why a monitoring area is selected (ex. tracking an issue)"

    static let yearlySchedule = "FRPA section 33 states that every RUP must include a schedule that includes livestock class, number and period of use for each pasture.\n\nEvery schedule must have at least one row in the schedule grid. The schedule description/narrative is optional but when included is legal content.\n\nOn/off schedules (off being on private land) are addressed using PLD % at the pasture level.\n\nStraggler clause is recorded using “grace days.” A default is entered for the pasture but it can be overwritten in the individual entries in the schedule as needed.\n\nStaff may either require that a schedule be provided for all plan years at the time of RUP approval OR that a new schedule be provided every year.\n\nOptions to copy an entire schedule to another year or to copy a single schedule row are available by selecting the three dots at the right."

    static let ministersIssuesandActions = "FRPA section 33 indicates that actions to to deal with issues identified by the minister must be specified in the RUP.\n\nIssues must be identified by the delegated decision maker (either on a site-specific basis or as a set of issues and conditions when they apply in a district) and documentation included on file before an RUP can be sent to an agreement holder for their input.\n\nRefer to the Minister’s Issue Policy for details on identifying issues for RUP content."

    static let identifiedbyMinistertoggle = "Do not move the toggle to “identified” until documentation regarding the identification by the delegated decision maker is on file."

    static let invasivePlants = "RPPR 15 indicates that an RUP must include measures to prevent the introduction and spread of invasive plant species if the the introduction, spread, or both are likely to be the result of the person’s range pracitices. This content is specific to the practices of the agreement holder not other crown land users.\n\nAll range practices have the potential to result in introduction or spread of invasive plants and this is a required section of the plan."

    static let additionalRequirements = "Other orders, agreements, plans etc. may have content that is relevant to range related activities. Inclusion of that content in the RUP is redundant and creates potential for inconsistency or error.\n\nThis section is included to inform the agreement holder and the decision maker of other agreements for consideration/review when preparing and making a decision on an RUP.\n\nWhen an agreement is available online include the URL for convenience."

    static let managementConsiderations = "Agreement holders may have information related to their operations that they want to have documented with their RUP. While not legal, this content can help explain the context for operations. This section is completely optional and fully within the domain of the agreement holder."

    static let approvedByMinister = "Place documentation of descision makers approval to include this plant community information on file before updating & sending to agreement holders."

    static let rangeReadinessOther = "Readiness may be expressed as a statement such as 'Soil sufficiently dry to prevent pugging'"
}

// Tooltip
/*
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

let tooltipPlantCommunityApprovedByMinisterTitle: String = "Approved By Minister"
let  tooltipPlantCommunityApprovedByMinisterDescription: String = "Place documentation of descision makers approval on file before updating & sending to agreement holders."
*/
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
