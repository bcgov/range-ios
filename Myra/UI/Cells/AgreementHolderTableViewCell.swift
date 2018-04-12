//
//  AgreementHolderTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementHolderTableViewCell: UITableViewCell {

    @IBOutlet weak var agreementHolder: UITextField!
    @IBOutlet weak var agreementType: UITextField!

    var client: Client?
    var parentCell: BasicInfoTableViewCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(client: Client, parentCell: BasicInfoTableViewCell) {
        self.agreementType.isUserInteractionEnabled = false
        self.agreementHolder.isUserInteractionEnabled = false
        self.client = client
        self.parentCell = parentCell
        autoFill()
    }

    func autoFill() {
        if let c = client {
            let clientType = RUPManager.shared.getClientTypeFor(clientTypeCode: c.clientTypeCode)
            self.agreementHolder.text = c.name
            self.agreementType.text = clientType.desc
        }
    }
    
}
