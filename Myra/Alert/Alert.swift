//
//  Alert.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Alert {

    private static let tag: Int = 96
    private static var height: CGFloat = 100

    // DYnamic sizes
    static let width: CGFloat = 270
    static let verticalContentPadding: CGFloat = 60
    static let paddingBetweenTitleAndMessage: CGFloat = 8
    static let horizontalContentPadding: CGFloat = 36
    static let buttonHeight: CGFloat = 43

    static let titleFont = Fonts.getPrimaryMedium(size: 18)
    static let messageFont = Fonts.getPrimary(size: 16)
    static let buttonFont = Fonts.getPrimaryMedium(size: 16)

    // White screen
    private static let whiteScreenTag: Int = 95
    private static let whiteScreenAlpha: CGFloat = 0.8

    static func show(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        estimateHeightWith(title: title, message: message)
        let view: AlertView = UIView.fromNib()
        view.setup(mode: .YesNo, title: title, message: message, rightButtonCallback: {
            view.removeFromSuperview()
            self.removeWhiteScreen()
            return yes()
        }, leftButtonCallBack: {
            view.removeFromSuperview()
            self.removeWhiteScreen()
            return no()
        })
        display(view: view)
    }

    static func show(title: String, message: String) {
        estimateHeightWith(title: title, message: message)
        let view: AlertView = UIView.fromNib()
        view.setup(mode: .Message, title: title, message: message, rightButtonCallback: {
            view.removeFromSuperview()
            self.removeWhiteScreen()
        }, leftButtonCallBack: {
            view.removeFromSuperview()
            self.removeWhiteScreen()
        })
        display(view: view)
    }

    private static func estimateHeightWith(title: String, message: String) {

        // This adds extra padding between message and the buttons
        let extraPadding: CGFloat = 8

        var h: CGFloat = 0
        h = title.height(withConstrainedWidth: width - horizontalContentPadding, font: titleFont)
        h += message.height(withConstrainedWidth: width - horizontalContentPadding, font: messageFont)
        h += buttonHeight
        h += verticalContentPadding
        h += extraPadding
        self.height = h
    }

    private static func display(view: UIView) {
        if let window = UIApplication.shared.keyWindow {
            addWhiteScreen()
            view.tag = tag

            // Position Icon
            let iconFrame = CGRect(x: (window.center.x - (self.width / 2)), y: (window.center.x - (self.height / 2)), width: self.width, height: self.height)

            view.frame = iconFrame
            view.center.y = window.center.y
            view.center.x = window.center.x
            window.addSubview(view)

            // Add constraints
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: self.width),
                view.heightAnchor.constraint(equalToConstant: self.height),
                view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                ])
        }

    }

    // MARK: White Screen
    private static func addWhiteScreen() {
        if let window = UIApplication.shared.keyWindow {
            let view = UIView(frame: window.frame)
            view.tag = self.whiteScreenTag
            view.center.x = window.center.x
            view.center.y = window.center.y
            view.backgroundColor = UIColor.white
            view.alpha = 0

            window.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: window.frame.width),
                view.heightAnchor.constraint(equalToConstant: window.frame.height),
                view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                ])
            UIView.animate(withDuration: 0.3) {
                view.alpha = self.whiteScreenAlpha
            }
        }
    }

    private static func removeWhiteScreen() {
        if let window = UIApplication.shared.keyWindow, let view = window.viewWithTag(self.whiteScreenTag) {
            UIView.animate(withDuration: 0.3) {
                view.removeFromSuperview()
            }
        }
    }

}
