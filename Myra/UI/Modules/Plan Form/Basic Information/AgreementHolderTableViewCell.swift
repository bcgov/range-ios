//
//  AgreementHolderTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementHolderTableViewCell: BaseFormCell {

    // MARK: Variables
    var client: Client?

    // MARK: Outlets
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var agreementHolder: UITextField!
    @IBOutlet weak var agreementType: UITextField!

    // MARK: Setup
    func setup(client: Client) {
        self.agreementType.isUserInteractionEnabled = false
        self.agreementHolder.isUserInteractionEnabled = false
        self.client = client
        autoFill()
        style()
    }

    func autoFill() {
        if let c = client {
            let clientType = Reference.shared.getClientTypeFor(clientTypeCode: c.clientTypeCode)
            self.agreementHolder.text = c.name
            self.agreementType.text = clientType.desc
        }
    }

    // MARK: Styles
    func style() {
        styleInputField(field: agreementType, editable: false, height: fieldHeight)
        styleInputField(field: agreementHolder,editable: false, height: fieldHeight)
    }
    
}
