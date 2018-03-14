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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setup(rup: RUP) {
        self.rangeNumber.text = "\(rup.agreementId)"
        self.agreementHolder.text = ""
        self.rangeName.text = rup.rangeName
    }
    
}
