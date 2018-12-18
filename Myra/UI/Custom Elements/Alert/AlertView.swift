//
//  Alert.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

enum AlertMode {
    case YesNo
    case Message
}

class AlertView: UIView, Theme {

    var rightButtonCallback: (()-> Void)?
    var leftButtonCallBack: (()-> Void)?
    var mode: AlertMode?

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var buttonsContainer: UIView!

    // Padding
    @IBOutlet weak var titleTopPadding: NSLayoutConstraint!
    @IBOutlet weak var messageTopPadding: NSLayoutConstraint!
    @IBOutlet weak var buttonsTopPadding: NSLayoutConstraint!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!

    @IBAction func leftButtonAction(_ sender: Any) {
        if let callback = self.leftButtonCallBack {
            return callback()
        }
    }

    @IBAction func rightButtonAction(_ sender: Any) {
        if let callback = self.rightButtonCallback {
            return callback()
        }
    }

    func setup(mode: AlertMode, title: String, message: String, rightButtonCallback: @escaping()-> Void, leftButtonCallBack: @escaping()-> Void) {
        self.mode = mode
        self.rightButtonCallback = rightButtonCallback
        self.leftButtonCallBack = leftButtonCallBack
        fill(title: title, message: message)
        style()
    }

    func fill(title: String, message: String) {
        self.title.text = title
        self.message.text = message
        self.adjustSizes(title: title)
    }

    func adjustSizes(title: String) {
        self.buttonHeight.constant = Alert.buttonHeight
        self.titleHeight.constant = title.height(withConstrainedWidth: Alert.width - Alert.horizontalContentPadding, font: Alert.titleFont)
        messageTopPadding.constant = Alert.paddingBetweenTitleAndMessage
        let remainingTopPadding = Alert.verticalContentPadding - Alert.paddingBetweenTitleAndMessage
        titleTopPadding.constant = remainingTopPadding / 2
        buttonsTopPadding.constant = remainingTopPadding / 2
        leftPadding.constant = Alert.horizontalContentPadding / 2
        rightPadding.constant = Alert.horizontalContentPadding / 2
    }

    func get(percent: CGFloat, of: CGFloat)-> CGFloat {
        return ((of * percent) / 100)
    }

    func style() {
        guard let mode = self.mode else {return}
        styleContainer(view: self)
        self.buttonsContainer.backgroundColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
        self.title.font = Alert.titleFont
        self.message.font = Alert.messageFont
        if let leftLabel = leftButton.titleLabel, let rightLabel = rightButton.titleLabel {
            leftLabel.font = Alert.buttonFont
            rightLabel.font = Alert.buttonFont
        }
        self.leftButton.setTitleColor(Colors.primary, for: .normal)
        self.rightButton.setTitleColor(Colors.primary, for: .normal)
        switch mode {
        case .YesNo:
            self.leftButton.setTitle("No", for: .normal)
            self.rightButton.setTitle("Yes", for: .normal)
        case .Message:
            self.leftButton.isHidden = true
            self.rightButton.setTitle("Okay", for: .normal)
        }

    }

}
