//
//  RangeUseageYearTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class RangeUseageYearTableViewCell: BaseFormCell {

    var usageYear: RangeUsageYear?

    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var authAUMs: UITextField!
    @IBOutlet weak var tempIncrease: UITextField!
    @IBOutlet weak var totalNonUse: UITextField!
    @IBOutlet weak var totalAnnual: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(usage: RangeUsageYear, bg: UIColor) {
        self.usageYear = usage
        if usageYear?.year != 0 {
            lockFields()
        }
        self.backgroundColor = bg
        autofill()
        style()
    }

    func autofill() {
        self.year.text = "\(usageYear?.year ?? 0)"
        self.authAUMs.text = "\(usageYear?.auth_AUMs ?? 0)"
        self.tempIncrease.text = "\(usageYear?.tempIncrease ?? 0)"
        self.totalNonUse.text = "\(usageYear?.totalNonUse ?? 0)"
        self.totalAnnual.text = "\(usageYear?.totalAnnual ?? 0)"
    }

    func lockFields() {
        self.year.isUserInteractionEnabled = false
        self.authAUMs.isUserInteractionEnabled = false
        self.tempIncrease.isUserInteractionEnabled = false
        self.totalNonUse.isUserInteractionEnabled = false
        self.totalAnnual.isUserInteractionEnabled = false
    }

    // MARK: Style
    func style() {
        styleInputField(field: year, editable: false, height: fieldHeight)
        styleInputField(field: authAUMs, editable: false, height: fieldHeight)
        styleInputField(field: tempIncrease, editable: false, height: fieldHeight)
        styleInputField(field: totalNonUse, editable: false, height: fieldHeight)
        styleInputField(field: totalAnnual, editable: false, height: fieldHeight)
    }
}
