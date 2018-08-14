//
//  AgreementTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementTableViewCell: UITableViewCell, Theme {

    var agreement: Agreement?

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var rangeNumber: UILabel!
    @IBOutlet weak var agreementHolder: UILabel!

    @IBAction func selectAction(_ sender: UIButton) {
        guard let current = agreement else {return}
        let parent = self.parentViewController as! SelectAgreementViewController
        parent.createPlanFor(agreement: current)
    }

    func setup(agreement: Agreement, bg: UIColor) {
        self.backgroundColor = bg
        self.rangeNumber.text = "\(agreement.agreementId)"
        self.agreementHolder.text = agreement.primaryAgreementHolder()
        style()
        self.agreement = agreement
    }

    func style() {
        styleStaticField(field: rangeNumber)
        styleStaticField(field: agreementHolder)
        styleFillButton(button: selectButton)
    }

    func styleSelected() {
        self.layer.shadowRadius = 8
    }

    func setLocked() {
        self.rangeNumber.textColor = Colors.oddCell
        self.agreementHolder.textColor = Colors.oddCell
    }
    
}
