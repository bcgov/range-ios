//
//  AmendmentPageThreeCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AmendmentPageThreeCollectionViewCell: BaseCollectionViewCell, Theme {

    // MARK: Constants
    let notification = UINotificationFeedbackGenerator()

    // MARK: Variables
    var amendment: Amendment?
    var parent: AmendmentFlowViewController?

    // MARK: Outlets
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

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
        parent.gotoPage(row: 1)
    }

    @IBAction func confirmAction(_ sender: UIButton) {
        guard let parent = self.parent else {return}
        if let amendment = self.amendment, let _ = amendment.type, amendment.InformedAgreementHolder {
            parent.remove()
        }
    }


    func setup(amendment: Amendment, parent: AmendmentFlowViewController) {
        self.parent = parent
        self.amendment = amendment
        style()
        autoFill()
    }

    func autoFill() {
        guard let amendment = self.amendment, let type = amendment.type else {return}
        self.subtitleLabel.text = "Are you ready to mark this Minor Ammendment as \(type)"
    }

    func style() {
        styleHollowButton(button: cancelButton)
        styleFillButton(button: confirmButton)
        styleSubHeader(label: titleLabel)
        styleFooter(label: subtitleLabel)
        styleDivider(divider: divide)
    }

}
