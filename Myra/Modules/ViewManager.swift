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
    
}
