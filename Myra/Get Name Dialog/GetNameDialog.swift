//
//  GetNameDialog.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Reachability

class GetNameDialog: UIView, Theme {

    // MARK: Variables
    private let width: CGFloat = 390
    private let height: CGFloat = 400
    private let animationDuration = 0.5
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0
    private let fieldErrorAnimationDuration = 2.0

    var callBack: (()-> Void)?

    // White screen
    private let whiteScreenTag: Int = 9532
    private let whiteScreenAlpha: CGFloat = 0.9

    // MARK: Outlets
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var viewSubtitle: UILabel!
    @IBOutlet weak var firstNameHeader: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameHeader: UILabel!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!

    // MARK: Outlet Actions
    @IBAction func submitAction(_ sender: UIButton) {
        guard let first = firstNameField.text, let last = lastNameField.text else {return}

        var valid: Bool = true

        if first.isEmpty {
            valid = false
            self.firstNameHeader.textColor = Colors.invalid
        }

        if last.isEmpty {
            valid = false
            self.lastNameHeader.textColor = Colors.invalid
        }

        if !valid {return}

        submitButton.isUserInteractionEnabled = false
        API.updateUserInfo(firstName: first, lastName: last) { (done) in
            if done {
                Alert.show(title: "Success", message: "Your information was successfully updated.")
                self.remove()
            } else {
                Alert.show(title: "There was an error", message: "We couldn't update your name at this time. we will ask you again later.")
                self.remove()
            }
            if let callback = self.callBack {
                return callback()
            }
        }
    }

    @IBAction func changedFirstName(_ sender: UITextField) {
        if let text = firstNameHeader.text, !text.isEmpty {
            firstNameHeader.textColor = Colors.bodyText
        }
    }

    @IBAction func changedLastName(_ sender: UITextField) {
        if let text = lastNameHeader.text, !text.isEmpty {
            lastNameHeader.textColor = Colors.bodyText
        }
    }

    // MARK: Entry Point
    func initialize(callBack: @escaping ()-> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.callBack = callBack
        style()
        window.isUserInteractionEnabled = false
        position {
            window.isUserInteractionEnabled = true
        }
        autoFill()
    }

    func autoFill() {
        guard let reachability = Reachability(), reachability.connection != .none else {
            return
        }
        Loading.shared.start()
        API.getUserInfo { (userInfo) in
            Loading.shared.stop()
            guard let userInfo = userInfo else {return}
            self.firstNameField.text = userInfo.firstName
            self.lastNameField.text = userInfo.lastName
        }
    }

    // MARK: Styles
    func style() {
        addShadow(layer: self.layer)
        viewTitle.font = Fonts.getPrimaryBold(size: 27)
        viewTitle.textColor = defaultFieldHeaderColor()
        viewSubtitle.font = Fonts.getPrimaryMedium(size: 17)
        viewSubtitle.textColor = defaultFieldHeaderColor()

        styleFillButton(button: submitButton)
        styleInputField(field: firstNameField, header: firstNameHeader, height: inputFieldHeight)
        styleInputField(field: lastNameField, header: lastNameHeader, height: inputFieldHeight)
    }

    // MARK: Positioning/ displaying
    func remove() {
        self.closingAnimation {
            self.removeWhiteScreen()
            self.removeFromSuperview()
        }
    }

    func position(then: @escaping ()-> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}

        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        //        self.center.x = window.center.x
        //        self.center.y = window.center.y
        //        self.centerXAnchor.constraint(equalTo: window.centerXAnchor)
        //        self.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        //        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0
        window.addSubview(self)
        addConstraints()

        showWhiteBG(then: {
            self.openingAnimation {
                return then()
            }
        })
    }

    func addConstraints() {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: height),
            self.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            ])
    }

    // MARK: Displaying animations
    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }

    func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.invisibleAlpha
        }) { (done) in
            then()
        }
    }

    // MARK: White Screen
    func showWhiteBG(then: @escaping()-> Void) {
        guard let window = UIApplication.shared.keyWindow, let bg = whiteScreen() else {return}

        bg.alpha = invisibleAlpha
        window.insertSubview(bg, belowSubview: self)
        bg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.centerXAnchor.constraint(equalTo:  window.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo:  window.centerYAnchor),
            bg.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            bg.topAnchor.constraint(equalTo: window.topAnchor),
            bg.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
        }) { (done) in
            return then()
        }

    }

    func whiteScreen() -> UIView? {
        guard let window = UIApplication.shared.keyWindow else {return nil}

        let view = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height))
        view.center.y = window.center.y
        view.center.x = window.center.x
        view.backgroundColor = Colors.active.blue.withAlphaComponent(0.2)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let viewWithTag = window.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }
}
