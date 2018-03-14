//
//  UIViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {


    ///Make sure storyboard file has same name as the class name
    public static func storyboardInstance() -> UIViewController?{
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let controller = storyboard.instantiateInitialViewController()
        return controller
    }
}

