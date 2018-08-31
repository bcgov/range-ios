//
//  Router.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-31.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Router {

    static var currentChildVC: UIViewController?

    static func add(childViewController viewController: UIViewController, to parentViewController: UIViewController) {
        self.currentChildVC = viewController
        parentViewController.addChildViewController(viewController)
        parentViewController.view.addSubview(viewController.view)
        viewController.view.frame = parentViewController.view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: parentViewController)
    }

    static func removeCurrentChild() {
        guard let currentChildVC = self.currentChildVC else { return }
        remove(asChildViewController: currentChildVC)
    }

    static func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }


}
