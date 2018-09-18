//
//  AmendmentPageOneCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AmendmentPageOneCollectionViewCell: BaseCollectionViewCell, Theme {

    // MARK: Constants
    let notification = UINotificationFeedbackGenerator()

    // MARK: Variables
    var amendment: Amendment?
    var parent: AmendmentFlowViewController?
    var mode: AmendmentFlowMode = .Minor

    // MARK: Outlets
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var optionZeroContainer: UIView!
    @IBOutlet weak var optionZeroIndicator: UIView!
    @IBOutlet weak var optionZeroLabel: UILabel!

    @IBOutlet weak var optionOneContainer: UIView!
    @IBOutlet weak var optionOneIndicator: UIView!
    @IBOutlet weak var optionOneLabel: UILabel!

    @IBOutlet weak var optionTwoContainer: UIView!
    @IBOutlet weak var optionTwoIndicator: UIView!
    @IBOutlet weak var optionTwoLabel: UILabel!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var divide: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        if let amendment = self.amendment, let _ = amendment.type {
            parent.gotoPage(row: 1)
        } else {
            fadeLabelMessage(label: subtitleLabel, text: "Select an updated amendment status below")
        }
    }

    @IBAction func closeAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        parent.remove(cancelled: true)
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        parent.remove(cancelled: true)
    }


    // only available in final review
    @IBAction func optionZeroAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        if self.mode == .FinalReview {
            amendment.type = .NotApprovedFurtherWorkRequired
        }
        autoFill()
    }

    @IBAction func optionOneAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        switch mode {
        case .Mandatory:
            amendment.type = .Ready
        case .Minor:
            amendment.type = .WronglyMadeStands
        case .FinalReview:
            amendment.type = .NotApproved
        case .Initial:
            amendment.type = .ChangeRequested
        }
        autoFill()
    }

    @IBAction func optionTwoAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        switch mode {
        case .Mandatory:
            amendment.type = .NotReady
        case .Minor:
            amendment.type = .WronglyMadeNoEffect
        case .FinalReview:
            amendment.type = .Approved
        case .Initial:
            amendment.type = .Completed
        }
        autoFill()
    }

    // MARK: Setup
    func setup(amendment: Amendment, mode: AmendmentFlowMode, parent: AmendmentFlowViewController) {
        self.mode = mode
        self.parent = parent
        self.amendment = amendment
        style()
        autoFill()
    }

    func autoFill() {
        guard let amendment = self.amendment else {return}
        if let type = amendment.type {
            switch type{
            case .Stands:
                selectOptionZero()
            case .WronglyMadeStands:
                selectOptionOne()
            case .WronglyMadeNoEffect:
                selectOptionTwo()
            case .Ready:
                selectOptionOne()
            case .NotReady:
                selectOptionTwo()
            case .NotApprovedFurtherWorkRequired:
                selectOptionZero()
            case .NotApproved:
                selectOptionOne()
            case .Approved:
                selectOptionTwo()
            case .Completed:
                selectOptionTwo()
            case .ChangeRequested:
                selectOptionOne()
            }
        } 
    }

    func style() {
        switch mode {
        case .Mandatory:
            self.optionOneLabel.text = "Ready"
            self.optionTwoLabel.text = "Not Ready"
            self.titleLabel.text = "Update Amendment Status"
            self.subtitleLabel.text = "Select an updated plan status below"
            self.optionZeroContainer.isHidden = true
        case .Minor:
            self.optionOneLabel.text = "Wrongly Made - Stands"
            self.optionTwoLabel.text = "Wrongly Made - Without Effect"
            self.titleLabel.text = "Update Amendment Status"
            self.subtitleLabel.text = "Select an updated amendment status below"
            self.optionZeroContainer.isHidden = true
        case .FinalReview:
            self.optionZeroLabel.text = "Not Approved - Further Work Required"
            self.optionOneLabel.text = "Not Approved"
            self.optionTwoLabel.text = "Approved"
            self.titleLabel.text = "Update Amendment Descision"
            self.subtitleLabel.text = "Select the final status of this Range Use Plan"
        case .Initial:
            self.optionOneLabel.text = "Change Requested"
            self.optionTwoLabel.text = "Completed"
            self.titleLabel.text = "Update Plan Status"
            self.subtitleLabel.text = "Select the new status of this Range Use Plan"
            self.optionZeroContainer.isHidden = true
        }
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
        makeCircle(view: optionZeroIndicator)
        makeCircle(view: optionOneIndicator)
        makeCircle(view: optionTwoIndicator)
        styleFieldHeader(label: optionZeroLabel)
        styleFieldHeader(label: optionOneLabel)
        styleFieldHeader(label: optionTwoLabel)
        optionZeroLabel.increaseFontSize(by: 3)
        optionOneLabel.increaseFontSize(by: 3)
        optionTwoLabel.increaseFontSize(by: 3)
        styleSubHeader(label: titleLabel)
        styleFooter(label: subtitleLabel)
        styleDivider(divider: divide)
        resetSelections()
    }

    func resetSelections() {
        optionZeroIndicator.layer.borderWidth = 1
        optionZeroIndicator.layer.borderColor = Colors.active.blue.cgColor
        optionZeroIndicator.backgroundColor = Colors.technical.backgroundTwo
        optionOneIndicator.layer.borderWidth = 1
        optionOneIndicator.layer.borderColor = Colors.active.blue.cgColor
        optionOneIndicator.backgroundColor = Colors.technical.backgroundTwo
        optionTwoIndicator.layer.borderWidth = 1
        optionTwoIndicator.layer.borderColor = Colors.active.blue.cgColor
        optionTwoIndicator.backgroundColor = Colors.technical.backgroundTwo
    }

    func selectOptionZero() {
        resetSelections()
        optionZeroIndicator.backgroundColor = Colors.active.blue
    }

    func selectOptionOne() {
        resetSelections()
        optionOneIndicator.backgroundColor = Colors.active.blue
    }

    func selectOptionTwo() {
        resetSelections()
        optionTwoIndicator.backgroundColor = Colors.active.blue
    }

}
