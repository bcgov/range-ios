//
//  AgreementTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var rangeNumber: UILabel!
    @IBOutlet weak var agreementHolder: UILabel!

    func setup(agreement: Agreement) {
        self.rangeNumber.text = "\(agreement.agreementId)"
        self.agreementHolder.text = RUPManager.shared.getPrimaryAgreementHolderFor(agreement: agreement)
        style()
    }

    func style() {
        styleStaticField(field: rangeNumber)
        styleStaticField(field: agreementHolder)
        styleFillButton(button: selectButton)
    }
    
}
