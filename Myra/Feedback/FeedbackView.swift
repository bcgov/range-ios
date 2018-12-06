//
//  FeedbackView.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class FeedbackView: UIView, Theme {

    let whiteScreenTag = 201
    let animationDuration = 0.5
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
            self.removeWhiteScreen()
            self.closingAnimation {
                self.removeFromSuperview()
                Feedback.initializeButton()
            }
        }
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        self.removeWhiteScreen()
        closingAnimation {
            self.removeFromSuperview()
            Feedback.initializeButton()
        }
    }


    func present(in vc: UIViewController) {
        Feedback.removeButton()
        self.parent = vc
        style()
        self.alpha = invisibleAlpha
        self.isUserInteractionEnabled = false
        self.viewHeight = vc.view.frame.height / 1.5
        self.viewWidth = vc.view.frame.width / 2
        position {
            self.isUserInteractionEnabled = true
        }
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

    // MARK: White Screen
    func whiteScreen(for vc: UIViewController) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height))
        view.center.y = vc.view.center.y
        view.center.x = vc.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: whiteScreenAlpha)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let parent = parent else {return}
        if let viewWithTag = parent.view.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }

    // MARK: Positioning/ displaying
    func position(then: @escaping ()-> Void) {
        guard let vc = self.parent else {return}
        self.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.center.x = vc.view.center.x
        self.center.y = vc.view.center.y
        self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        self.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(self)

        // Add constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: viewWidth),
            self.heightAnchor.constraint(equalToConstant: viewHeight),
            self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        // White screen
        let bg = whiteScreen(for: vc)
        bg.alpha = invisibleAlpha
        vc.view.insertSubview(bg, belowSubview: self)
        NSLayoutConstraint.activate([
            bg.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
            bg.heightAnchor.constraint(equalTo:  vc.view.heightAnchor),
            bg.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
            self.openingAnimation {
                return then()
            }
        })
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

}
