//
//  UIApplication.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-30.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {

    class func vc<T:UIViewController>(vcKind:T.Type? = nil) -> T?{
        guard let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        if let vc = appDelegate.window?.rootViewController as? T {
            return vc
        }else if let vc = appDelegate.window?.rootViewController?.presentedViewController as? T {
            return vc
        }else if let vc = appDelegate.window?.rootViewController?.childViewControllers  {
            return vc.lazy.flatMap{$0 as? T}.first
        }
        return nil
    }

    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
