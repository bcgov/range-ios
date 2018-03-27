//
//  RangeUseageYearTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class RangeUseageYearTableViewCell: UITableViewCell {

    var usageYear: RangeUsageYear?

    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var auth_AUMs: UITextField!
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

    func setup(usage: RangeUsageYear) {
        self.usageYear = usage
        if usageYear?.year != 0 {
            lockFields()
        }
        autofill()
    }

    func autofill() {
        self.year.text = "\(usageYear?.year ?? 0)"
        self.auth_AUMs.text = "\(usageYear?.auth_AUMs ?? 0)"
        self.tempIncrease.text = "\(usageYear?.tempIncrease ?? 0)"
        self.totalNonUse.text = "\(usageYear?.totalNonUse ?? 0)"
        self.totalAnnual.text = "\(usageYear?.totalAnnual ?? 0)"
    }

    func lockFields() {
        self.year.isUserInteractionEnabled = false
        self.auth_AUMs.isUserInteractionEnabled = false
        self.tempIncrease.isUserInteractionEnabled = false
        self.totalNonUse.isUserInteractionEnabled = false
        self.totalAnnual.isUserInteractionEnabled = false
    }
    
}
