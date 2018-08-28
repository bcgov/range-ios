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

    // MARK: Outlets
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var standsModule: UIView!
    @IBOutlet weak var amendmentStandsIndicator: UIView!
    @IBOutlet weak var amendmentStandsLabel: UILabel!

    @IBOutlet weak var wmStandsModule: UIView!
    @IBOutlet weak var wronglyMadeStandsIndicator: UIView!
    @IBOutlet weak var wronglyMadeStandsLabel: UILabel!

    @IBOutlet weak var vmNoEffectModule: UIView!
    @IBOutlet weak var wronglyMadeNoEffectIndicator: UIView!
    @IBOutlet weak var wronglyMadeNoEffectLabel: UILabel!

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
        parent.remove()
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        parent.remove()
    }

    @IBAction func amendmentStandsAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        amendment.type = .Stands
        autoFill()
    }

    @IBAction func wronglyMadeStandsAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        amendment.type = .WronglyMadeStands
        autoFill()
    }

    @IBAction func wronglyMadeNoEffectAction(_ sender: UIButton) {
        guard let amendment = self.amendment else {return}
        amendment.type = .WronglyMadeNoEffect
        autoFill()
    }

    // MARK: Setup
    func setup(amendment: Amendment, parent: AmendmentFlowViewController) {
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
                toggleAmendmentStands()
            case .WronglyMadeStands:
                toggleWronglyMadeStands()
            case .WronglyMadeNoEffect:
                toggleWronglyMadeNoEffect()
            }
        } 
    }

    func style() {
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
        makeCircle(view: amendmentStandsIndicator)
        makeCircle(view: wronglyMadeStandsIndicator)
        makeCircle(view: wronglyMadeNoEffectIndicator)
        styleFieldHeader(label: amendmentStandsLabel)
        styleFieldHeader(label: wronglyMadeStandsLabel)
        styleFieldHeader(label: wronglyMadeNoEffectLabel)
        styleSubHeader(label: titleLabel)
        styleFooter(label: subtitleLabel)
        styleDivider(divider: divide)
        resetSelections()

        //  USED FOR DEBUGGING - set false to show stands option
//        self.standsModule.isHidden = true
    }

    func resetSelections() {
        amendmentStandsIndicator.layer.borderWidth = 1
        amendmentStandsIndicator.layer.borderColor = Colors.active.blue.cgColor
        amendmentStandsIndicator.backgroundColor = Colors.technical.backgroundTwo
        wronglyMadeStandsIndicator.layer.borderWidth = 1
        wronglyMadeStandsIndicator.layer.borderColor = Colors.active.blue.cgColor
        wronglyMadeStandsIndicator.backgroundColor = Colors.technical.backgroundTwo
        wronglyMadeNoEffectIndicator.layer.borderWidth = 1
        wronglyMadeNoEffectIndicator.layer.borderColor = Colors.active.blue.cgColor
        wronglyMadeNoEffectIndicator.backgroundColor = Colors.technical.backgroundTwo
    }

    func toggleAmendmentStands() {
        resetSelections()
        amendmentStandsIndicator.backgroundColor = Colors.active.blue
    }

    func toggleWronglyMadeStands() {
        resetSelections()
        wronglyMadeStandsIndicator.backgroundColor = Colors.active.blue
    }

    func toggleWronglyMadeNoEffect() {
        resetSelections()
        wronglyMadeNoEffectIndicator.backgroundColor = Colors.active.blue
    }

}
