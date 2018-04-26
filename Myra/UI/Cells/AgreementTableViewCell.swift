//
//  AgreementTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementTableViewCell: UITableViewCell {

    @IBOutlet weak var rangeNumber: UILabel!
    @IBOutlet weak var agreementHolder: UILabel!
    @IBOutlet weak var rangeName: UILabel!

    func setup(agreement: Agreement) {
        self.rangeNumber.text = "\(agreement.agreementId)"
        self.agreementHolder.text = ""
        self.rangeName.text = ""
    }
    
}
