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
    @IBOutlet weak var rangeNumber: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var startDate: UITextField!
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
            self.rangeNumber.text = object?.rangeNumber
            self.startDate.text = object?.agreementStart.string()
            self.endDate.text = object?.agreementEnd.string()
        }
    }

    func setFieldTypes() {
        
    }

}
