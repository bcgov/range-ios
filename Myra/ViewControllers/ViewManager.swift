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
    static let shared = ViewManager()
    
    private init() {}

    lazy var rupDetails: RUPDetailsViewController = {
        return UIStoryboard(name: "RUPDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "RUPDetails") as! RUPDetailsViewController
    }()

    lazy var create: CreateViewController = {
        return UIStoryboard(name: "Create", bundle: Bundle.main).instantiateViewController(withIdentifier: "Create") as! CreateViewController
    }()

    lazy var createRUP: CreateNewRUPViewController = {
        return UIStoryboard(name: "CreateNewRup", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateNewRup") as! CreateNewRUPViewController
    }()

    lazy var schedule: ScheduleViewController = {
        return UIStoryboard(name: "Schedule", bundle: Bundle.main).instantiateViewController(withIdentifier: "Schedule") as! ScheduleViewController
    }()
    
}
