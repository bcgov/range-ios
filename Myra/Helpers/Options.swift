//
//  Options.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation


class Options {
    static let shared = Options()
    private init() {}

    func getMinistersIssueTypesOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = Reference.shared.getIssueType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getMinistersIssueActionsOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = Reference.shared.getIssueActionType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPlanCommunityTypeOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        options.append(SelectionPopUpObject(display: "Pinegrass"))
        options.append(SelectionPopUpObject(display: "Something"))
        options.append(SelectionPopUpObject(display: "Something else"))
        return options
    }

    func getPlantCommunityAspectLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()

        for i in 0...3 {
            returnArray.append(SelectionPopUpObject(display: "option \(i)"))
        }

        return returnArray
    }

    func getPlantCommunityElevationLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "- <500"))
        returnArray.append(SelectionPopUpObject(display: "500-699"))
        returnArray.append(SelectionPopUpObject(display: "700-899"))
        returnArray.append(SelectionPopUpObject(display: "900-1099"))
        returnArray.append(SelectionPopUpObject(display: "1100-1299"))
        returnArray.append(SelectionPopUpObject(display: "1300-1500"))
        returnArray.append(SelectionPopUpObject(display: ">1500"))
        return returnArray
    }

    func getPlantCommunityPurposeOfActionsLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Establish Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Maintain Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Clear"))
        return returnArray
    }

    func getRangeLandHealthLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
         returnArray.append(SelectionPopUpObject(display: "Properly Functioning Condition"))
        returnArray.append(SelectionPopUpObject(display: "Slightly at risk"))
        returnArray.append(SelectionPopUpObject(display: "Moderately at risk"))
        returnArray.append(SelectionPopUpObject(display: "Highly at risk"))
        returnArray.append(SelectionPopUpObject(display: "Non-functional"))


        return returnArray
    }

    func getMonitoringAreaPurposeLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Key Area"))
        returnArray.append(SelectionPopUpObject(display: "Criteria"))
        returnArray.append(SelectionPopUpObject(display: "Other"))
        return returnArray
    }

    func getPastureActionLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Herding"))
        returnArray.append(SelectionPopUpObject(display: "Livestock variables"))
        returnArray.append(SelectionPopUpObject(display: "Salting"))
        returnArray.append(SelectionPopUpObject(display: "Supplemental"))
        returnArray.append(SelectionPopUpObject(display: "Timing"))
        returnArray.append(SelectionPopUpObject(display: "Other"))
        return returnArray
    }
    func getIndicatorPlantLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Pinegrass"))
        returnArray.append(SelectionPopUpObject(display: "Idaho Fescue"))
        return returnArray
    }

    func getPasturesLookup(rup: RUP) -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let names = getPastureNames(rup: rup)
        for name in names {
            returnArray.append(SelectionPopUpObject(display: name, value: name))
        }
        return returnArray
    }

    func getPastureNames(rup: RUP) -> [String] {
        var names = [String]()
        for pasture in rup.pastures {
            names.append(pasture.name)
        }
        return names
    }

    func getPastureNamed(name: String, rup: RUP) -> Pasture? {
        for pasture in rup.pastures {
            if pasture.name == name {
                return pasture
            }
        }
        return nil
    }

    func getRANLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let agreements = RUPManager.shared.getAgreements()
        for agreement in agreements {
            returnArray.append(SelectionPopUpObject(display: agreement.agreementId))
        }
        return returnArray
    }

    func getManagementConsiderationLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Option-1"))
        returnArray.append(SelectionPopUpObject(display: "Option-2"))
        returnArray.append(SelectionPopUpObject(display: "Option-3"))
        returnArray.append(SelectionPopUpObject(display: "Option-4"))
        returnArray.append(SelectionPopUpObject(display: "Option-5"))
        return returnArray
    }

    func getAdditionalRequirementLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Option-1"))
        returnArray.append(SelectionPopUpObject(display: "Option-2"))
        returnArray.append(SelectionPopUpObject(display: "Option-3"))
        returnArray.append(SelectionPopUpObject(display: "Option-4"))
        returnArray.append(SelectionPopUpObject(display: "Option-5"))
        return returnArray
    }
}
