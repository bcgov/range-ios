//
//  GetNameDialog.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Reachability

class GetNameDialog: CustomModal {

    // MARK: Variables
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0

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
        self.endEditing(true)
        Loading.shared.start()
        API.updateUserInfo(firstName: first, lastName: last) { (done) in
            Loading.shared.stop()
            if done {
                Alert.show(title: Constants.Alerts.UserInfoUpdate.Success.title, message: Constants.Alerts.UserInfoUpdate.Success.message)
                SettingsManager.shared.setUser(firstName: first, lastName: last)
                self.remove()
            } else {
                Alert.show(title: Constants.Alerts.UserInfoUpdate.Fail.title, message: Constants.Alerts.UserInfoUpdate.Fail.message)
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
        // Can't change user info if we're not authenticated
        if !Auth.isAuthenticated() {return}
        
        self.callBack = callBack
        setSmartSizingWith(percentHorizontalPadding: 30, percentVerticalPadding: 35)
        style()
        present()
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
            SettingsManager.shared.setUser(info: userInfo)
        }
    }

    // MARK: Styles
    func style() {
        styleModalBox()
        addShadow(layer: self.layer)
        viewTitle.font = Fonts.getPrimaryBold(size: 27)
        viewTitle.textColor = defaultFieldHeaderColor()
        viewSubtitle.font = Fonts.getPrimaryMedium(size: 17)
        viewSubtitle.textColor = defaultFieldHeaderColor()

        styleFillButton(button: submitButton)
        styleInputField(field: firstNameField, header: firstNameHeader, height: inputFieldHeight)
        styleInputField(field: lastNameField, header: lastNameHeader, height: inputFieldHeight)
    }
}
