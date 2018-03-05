//
//  BasicInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BasicInformationTableViewCell: UITableViewCell {

    // Mark: Variables
    var mode: FormMode = .Create
    var object: BasicInformation?

    // Mark: Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var rangeNumberField: UITextField!
    @IBOutlet weak var planStartField: UITextField!
    @IBOutlet weak var agreementStartDateField: UITextField!
    @IBOutlet weak var agreementTypeField: UITextField!
    @IBOutlet weak var planEndDateField: UITextField!
    @IBOutlet weak var agreementEndDateField: UITextField!
    @IBOutlet weak var districtResponsibleField: UITextField!
    @IBOutlet weak var zoneField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        if object != nil {
            autofill()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    // Mark: Functions
    func setup(mode: FormMode, object: BasicInformation) {
        self.mode = mode
        self.object = object
    }

    func autofill() {
        if object != nil { return }
        if mode == .View || mode == .Edit {
            self.rangeNumberField.text = object?.rangeNumber
            self.planStartField.text = object?.planStart.string()
            self.agreementStartDateField.text = object?.agreementStart.string()
            self.agreementTypeField.text = object?.agreementType
            self.planEndDateField.text = object?.planEnd.string()
            self.agreementEndDateField.text = object?.agreementEnd.string()
            self.districtResponsibleField.text = object?.district
            self.zoneField.text = object?.RUPzone
        }
    }

}
