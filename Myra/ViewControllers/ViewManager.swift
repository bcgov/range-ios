//
//  ViewManager.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class ViewManager {

    lazy var home: HomeViewController = {
        return UIStoryboard(name: "Home", bundle: Bundle.main).instantiateViewController(withIdentifier: "Home") as! HomeViewController
    }()

    lazy var login: LoginViewController = {
        return UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login") as! LoginViewController
    }()

    lazy var createRUP: CreateNewRUPViewController = {
        return UIStoryboard(name: "CreateNewRup", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateNewRup") as! CreateNewRUPViewController
    }()

    lazy var schedule: ScheduleViewController = {
        return UIStoryboard(name: "Schedule", bundle: Bundle.main).instantiateViewController(withIdentifier: "Schedule") as! ScheduleViewController
    }()

    lazy var plantCommunity: PlantCommunityViewController = {
        return UIStoryboard(name: "PlantCommunity", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlantCommunity") as! PlantCommunityViewController
    }()

    lazy var selectAgreement: SelectAgreementViewController = {
        return UIStoryboard(name: "SelectAgreement", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectAgreement") as! SelectAgreementViewController
    }()

    lazy var lookup: SelectionPopUpViewController = {
        return UIStoryboard(name: "SelectionPopup", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectionPopUp") as! SelectionPopUpViewController
    }()

    lazy var datePicker: DatePickerViewController = {
        return UIStoryboard(name: "DatePicker", bundle: Bundle.main).instantiateViewController(withIdentifier: "DatePicker") as! DatePickerViewController
    }()

    lazy var options: OptionsViewController = {
        return UIStoryboard(name: "Options", bundle: Bundle.main).instantiateViewController(withIdentifier: "Options") as! OptionsViewController
    }()

    lazy var textEntry: TextEntryViewController = {
        return UIStoryboard(name: "TextEntry", bundle: Bundle.main).instantiateViewController(withIdentifier: "TextEntry") as! TextEntryViewController
    }()
}
