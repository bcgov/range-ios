//
//  AmendmentPageTwoCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AmendmentPageTwoCollectionViewCell: BaseCollectionViewCell, Theme {

    // MARK: Constants
    let notification = UINotificationFeedbackGenerator()

    // MARK: Variables
    var amendment: Amendment?
    var parent: AmendmentFlowViewController?

    // MARK: Outlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var informedIndicatorImageView: UIImageView!
    @IBOutlet weak var informedIndicator: UIView!
    @IBOutlet weak var informedLabel: UILabel!

    @IBOutlet weak var divide: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func closeAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        parent.remove()
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        parent.gotoPage(row: 0)
    }

    @IBAction func nextAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        if let amendment = self.amendment, amendment.InformedAgreementHolder {
            parent.gotoPage(row: 2)
        } else {
            fadeLabelMessage(label: subtitleLabel, text: "Please confirm that you have informed agreement holder of the status")
//            warnRequiredField()
        }
    }

    @IBAction func toggleInformed(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        amendment.InformedAgreementHolder = !amendment.InformedAgreementHolder
        autoFill()
    }

    func setup(amendment: Amendment, parent: AmendmentFlowViewController) {
        self.parent = parent
        self.amendment = amendment
        style()
        autoFill()
    }

    func autoFill() {
        guard let amendment = self.amendment, let type = amendment.type else {return}
        if amendment.InformedAgreementHolder {
            toggleInformed()
        } else {
            informedIndicator.layer.borderWidth = 1
            informedIndicator.layer.borderColor = Colors.active.blue.cgColor
            informedIndicator.backgroundColor = Colors.technical.backgroundTwo
            informedIndicatorImageView.alpha = 0
        }
        self.textView.text = amendment.notes
        self.subtitleLabel.text = "Are you ready to mark this Minor Amendment as \(type)"
        self.informedLabel.text = "I Have informed the agreement holder of the \(type)"
    }

    func style() {
        informedIndicator.layer.borderWidth = 1
        informedIndicator.layer.borderColor = Colors.active.blue.cgColor
        informedIndicator.backgroundColor = Colors.technical.backgroundTwo
        informedIndicatorImageView.image = nil
        makeCircle(view: informedIndicator)
        styleFieldHeader(label: informedLabel)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
        styleSubHeader(label: titleLabel)
        styleFooter(label: subtitleLabel)
        styleDivider(divider: divide)
        styleTextviewInputField(field: textView)
    }

    func toggleInformed() {
//        informedIndicator.backgroundColor = Colors.active.blue
        informedIndicatorImageView.alpha = 1
        informedIndicatorImageView.image = #imageLiteral(resourceName: "icon_check")
    }


    func warnRequiredField() {
        // fade out current text
        UIView.animate(withDuration: 0.2, animations: {
            self.subtitleLabel.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            // change text
            self.subtitleLabel.text = "Please confirm that you have informed agreement holder of the status"
            // fade in warning text
            UIView.animate(withDuration: 0.2, animations: {
                self.subtitleLabel.textColor = Colors.accent.red
                self.subtitleLabel.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: 0.2, delay: 3, animations: {
                    // fade out text
                    self.subtitleLabel.alpha = 0
                    self.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    self.subtitleLabel.text = "Are you ready to mark this Minor Amendment as"
                    // fade in text
                    UIView.animate(withDuration: 0.2, animations: {
                        self.styleFooter(label: self.subtitleLabel)
                        self.subtitleLabel.alpha = 1
                        self.layoutIfNeeded()
                    })
                })
            })
        }
    }
}

// MARK: Notes
extension AmendmentPageTwoCollectionViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let amendment = self.amendment else {return}
        amendment.notes = textView.text
    }
}

