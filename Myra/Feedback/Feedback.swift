//
//  Feedback.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class Feedback: NSObject {

    static let buttonTag = 666881
    static var displayedButton: UIButton?


    static func initializeButton() {
        if let current = Feedback.displayedButton {
            current.removeFromSuperview()
        }

        guard let r = Reachability() else {return}
        if r.connection == .none {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if r.connection == .none {
                return
            }
            if let current = Feedback.displayedButton {
                current.removeFromSuperview()
            }
            if let window = UIApplication.shared.keyWindow {
                let padding: CGFloat = 5
                let width: CGFloat = 43
                let height: CGFloat = 43
                let frame = CGRect(x: padding, y: ((window.frame.maxY - height) - padding), width: width, height: height)
                let button = UIButton(frame: frame)
                button.setImage(UIImage(named: "icon_Question"), for: .normal)
                button.addTarget(self, action: #selector(Feedback.buttonAction), for: .touchUpInside)
                button.tag = buttonTag
                window.addSubview(button)
                Feedback.displayedButton = button
            }
        }
    }

    @objc static func buttonAction() {
        getPresented { (vc) in
            if let current = vc {
                Feedback.show(in: current)
            }
        }
    }

    static func removeButton() {
        if let current = Feedback.displayedButton {
            current.removeFromSuperview()
        }
    }

    static func getPresented(callback: @escaping(_ vc: UIViewController?)-> Void) {
        if Thread.isMainThread {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let vc = root.children.last {
                if let presented = vc.presentedViewController {
                    if let deeper = presented.presentedViewController {
                        return callback(deeper)
                    } else {
                        return callback(presented)
                    }
                } else {
                    return callback(vc)
                }
            } else {
                return callback(nil)
            }
        } else {
            DispatchQueue.main.sync {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let vc = root.children.last  {
                    if let presented = vc.presentedViewController {
                        if let deeper = presented.presentedViewController {
                            return callback(deeper)
                        } else {
                            return callback(presented)
                        }
                    } else {
                        return callback(vc)
                    }
                } else {
                    return callback(nil)
                }
            }
        }
    }

    static func show(in vc: UIViewController) {
        let view: FeedbackView = UIView.fromNib()
        removeButton()
        view.present(in: vc)
    }

    static func send(feedback: FeedbackElement, completion: @escaping (_ success: Bool)->Void) {
        guard let endpoint = URL(string: Constants.API.feedbackPath, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }
        API.post(endpoint: endpoint, params: feedback.toDictionary()) { (response) in
            return completion(true)
        }
    }
}
