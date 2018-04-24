//
//  AgreementHolderTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementHolderTableViewCell: BaseFormCell {

    // TODO: Clean up

    @IBOutlet weak var agreementHolder: UITextField!
    @IBOutlet weak var agreementType: UITextField!

    var client: Client?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(client: Client) {
        self.agreementType.isUserInteractionEnabled = false
        self.agreementHolder.isUserInteractionEnabled = false
        self.client = client
        autoFill()
        style()
    }

    func autoFill() {
        if let c = client {
            let clientType = RUPManager.shared.getClientTypeFor(clientTypeCode: c.clientTypeCode)
            self.agreementHolder.text = c.name
            self.agreementType.text = clientType.desc
        }
    }

    func style() {
        styleInputField(field: agreementType, editable: false)
        styleInputField(field: agreementHolder,editable: false)
    }
    
}
