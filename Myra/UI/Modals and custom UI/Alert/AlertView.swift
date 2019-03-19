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

class AlertView: CustomModal {

    // MARK: Variables
    var rightButtonCallback: (()-> Void)?
    var leftButtonCallBack: (()-> Void)?
    var mode: AlertMode?
    
    let titleFont = Fonts.getPrimaryMedium(size: 18)
    let messageFont = Fonts.getPrimary(size: 16)
    let buttonFont = Fonts.getPrimaryMedium(size: 16)
    
    let verticalContentPadding: CGFloat = 60
    let paddingBetweenTitleAndMessage: CGFloat = 8
    let horizontalContentPadding: CGFloat = 36
    let buttonHeightConst: CGFloat = 43
    
    let width: CGFloat = 270

    // MARK: Outlets
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

    // MARK: Outlet Actions
    @IBAction func leftButtonAction(_ sender: Any) {
        if let callback = self.leftButtonCallBack {
            self.remove()
            return callback()
        }
    }

    @IBAction func rightButtonAction(_ sender: Any) {
        if let callback = self.rightButtonCallback {
            self.remove()
            return callback()
        }
    }
    
    // MARK: Initialization
    func initialize(mode: AlertMode, title: String, message: String, rightButtonCallback: @escaping()-> Void, leftButtonCallBack: @escaping()-> Void) {
        setFixed(width: width, height: estimateHeightWith(title: title, message: message))
        self.mode = mode
        self.rightButtonCallback = rightButtonCallback
        self.leftButtonCallBack = leftButtonCallBack
        fill(title: title, message: message)
        present()
        style()
    }

    // MARK: Autofill
    func fill(title: String, message: String) {
        self.title.text = title
        self.message.text = message
        self.adjustSizes(title: title)
    }
    
    // MARK: Dynamic Height
    private func estimateHeightWith(title: String, message: String) -> CGFloat {
        
        // This adds extra padding between message and the buttons
        let extraPadding: CGFloat = 8
        
        var h: CGFloat = 0
        h = title.height(withConstrainedWidth: width - horizontalContentPadding, font: titleFont)
        h += message.height(withConstrainedWidth: width - horizontalContentPadding, font: messageFont)
        h += buttonHeightConst
        h += verticalContentPadding
        h += extraPadding
        return h
    }

    func adjustSizes(title: String) {
        self.buttonHeight.constant = buttonHeightConst
        self.titleHeight.constant = title.height(withConstrainedWidth: width - horizontalContentPadding, font: titleFont)
        messageTopPadding.constant = paddingBetweenTitleAndMessage
        let remainingTopPadding = verticalContentPadding - paddingBetweenTitleAndMessage
        titleTopPadding.constant = remainingTopPadding / 2
        buttonsTopPadding.constant = remainingTopPadding / 2
        leftPadding.constant = horizontalContentPadding / 2
        rightPadding.constant = horizontalContentPadding / 2
    }

    // MARK: Style
    func style() {
        guard let mode = self.mode else {return}
        styleContainer(view: self)
        self.buttonsContainer.backgroundColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
        self.title.font = titleFont
        self.message.font = messageFont
        if let leftLabel = leftButton.titleLabel, let rightLabel = rightButton.titleLabel {
            leftLabel.font = buttonFont
            rightLabel.font = buttonFont
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
