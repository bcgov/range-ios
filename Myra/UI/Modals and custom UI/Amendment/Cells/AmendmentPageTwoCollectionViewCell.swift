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
    var parent: AmendmentFlow?
    var mode: AmendmentFlowMode = .Minor

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
        guard let parent = self.parent, let amendment = self.amendment, let type = amendment.type else {return}

        let statusChangeMessage = "Please confirm that you have informed the agreement holder about the status change."

//        // checkbox is mandatory
//        if !amendment.InformedAgreementHolder {
//            fadeLabelMessage(label: subtitleLabel, text: statusChangeMessage)
//            return
//        }
        switch mode {
        case .Minor:
            // checkbox is mandatory
            if !amendment.InformedAgreementHolder {
                fadeLabelMessage(label: subtitleLabel, text: statusChangeMessage)
                return
            } else {
                parent.gotoPage(row: 2)
            }
        case .Mandatory:
            // Checkbox is only required in not ready state
            if type == .NotReady && !amendment.InformedAgreementHolder {
                fadeLabelMessage(label: subtitleLabel, text: statusChangeMessage)
                return
            } else {
                parent.gotoPage(row: 2)
            }
        case .FinalReview:
            // checkbox is mandatory
            if !amendment.InformedAgreementHolder {
                fadeLabelMessage(label: subtitleLabel, text: statusChangeMessage)
                return
            } else {
            // Notes are necessary unless approved has been selected
                // TODO: dont check  self.textView.text.count, check amendment.notes. (not yet storing notes)
                if type != .Approved && self.textView.text.count < 1 {
                    fadeLabelMessage(label: subtitleLabel, text: "Please describe why this plan is not Not Approved")
                    return
                } else {
                    parent.gotoPage(row: 2)
                }
            }
        case .Initial:
            if !amendment.InformedAgreementHolder {
                fadeLabelMessage(label: subtitleLabel, text: statusChangeMessage)
                return
            } else {
                parent.gotoPage(row: 2)
            }
        case .Create:
            // no checkbox
            parent.gotoPage(row: 2)
        case .ReturnToAgreementHolder:
            // TODO: HERE!!!
            break
        }
    }

    @IBAction func toggleInformed(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        amendment.InformedAgreementHolder = !amendment.InformedAgreementHolder
        styleSelection()
    }

    func setup(amendment: Amendment, mode: AmendmentFlowMode, parent: AmendmentFlow) {
        self.mode = mode
        self.parent = parent
        self.amendment = amendment
        style()
        autoFill()
    }

    func autoFill() {
        guard let amendment = self.amendment, let type = amendment.type else {return}
        styleSelection()
        self.textView.text = amendment.notes
        var thisThing = "Plan"
        if mode == .Mandatory || mode == .Minor {
            thisThing = "\(mode) Amendment"
        }

        let typeString: String = "\(type)"

        self.subtitleLabel.text = "Are you ready to mark this \(thisThing) as \(typeString.convertFromCamelCase().uppercased())?"
        self.informedLabel.text = "I Have informed the agreement holder about the *\(typeString.convertFromCamelCase()) status*"

        if mode == .Create {
            self.informedIndicator.alpha = 0
            self.informedLabel.alpha = 0
            self.subtitleLabel.text = "Add Description. (Visible to staff and agreement holders.)"
        }
    }

    func styleSelection() {
        guard let amendment = self.amendment else {return}
        if amendment.InformedAgreementHolder {
            toggleInformed()
        } else {
            informedIndicator.layer.borderWidth = 1
            informedIndicator.layer.borderColor = Colors.active.blue.cgColor
            informedIndicator.backgroundColor = Colors.technical.backgroundTwo
            informedIndicatorImageView.alpha = 0
        }
    }

    func style() {
        switch mode {
        case .Mandatory:
            self.titleLabel.text = "Update Amendment Status"
        case .Minor:
            self.titleLabel.text = "Update Amendment Status"
        case .FinalReview:
            self.titleLabel.text = "Update Amendment Descision"
        case .Initial:
            self.titleLabel.text = "Update Plan Status"
        case .Create:
            self.titleLabel.text = "Ready to Submit?"
        case .ReturnToAgreementHolder:
            // TODO: HERE!!!
            break
        }
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
        informedIndicatorImageView.alpha = 1
        informedIndicatorImageView.image = #imageLiteral(resourceName: "icon_check")
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

