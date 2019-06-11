//
//  FeedbackView.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class FeedbackView: CustomModal {

    let whiteScreenTag = 201
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    let whiteScreenAlpha: CGFloat = 0.9

    var viewWidth: CGFloat = 390
    var viewHeight: CGFloat = 400

    var parent: UIViewController?

    @IBOutlet weak var sectionNameHeight: NSLayoutConstraint!
    @IBOutlet weak var sectionNameHeader: UILabel!
    @IBOutlet weak var sectionNameField: UITextField!
    @IBOutlet weak var anonHeader: UILabel!
    @IBOutlet weak var anonSwitch: UISwitch!
    @IBOutlet weak var feedbackHeader: UILabel!
    @IBOutlet weak var feedbackField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var anonInfo: UILabel!
    @IBOutlet weak var divider: UIView!

    @IBAction func sendAction(_ sender: Any) {
        guard let feedback = feedbackField.text, let section = sectionNameField.text else {return}
        let element = FeedbackElement(feedback: feedback, section: section, anonymous: anonSwitch.isOn)
        Feedback.send(feedback: element) { (success) in
            self.remove()
            Feedback.initializeButton()
        }
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        self.removeWhiteScreen()
        remove()
        Feedback.initializeButton()
    }

    func initialize() {
        Feedback.removeButton()
        style()
        setSmartSizingWith(horizontalPadding: 200, verticalPadding: 100)
        present()
    }
    
    func style() {
        styleDivider(divider: divider)
        viewTitle.font = Fonts.getPrimaryBold(size: 22)
        viewTitle.textColor = Colors.active.blue
        styleFieldHeader(label: anonInfo)
        styleContainer(view: self)
        styleInputField(field: sectionNameField, header: sectionNameHeader, height: sectionNameHeight)
        styleTextviewInputField(field: feedbackField, header: feedbackHeader)
        styleFillButton(button: sendButton)
        styleHollowButton(button: cancelButton)
        styleFieldHeader(label: anonHeader)
    }
}
