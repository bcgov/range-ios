//
//  PlanInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-24.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlanInformationTableViewCell: BaseFormCell {

    // MARK: Constants

    // MARK: Variables

    // MARK: Outlets
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var header: UILabel!

    @IBOutlet weak var planStartHeader: UILabel!
    @IBOutlet weak var planStartValue: UITextField!

    @IBOutlet weak var planEndHeader: UILabel!
    @IBOutlet weak var planEndValue: UITextField!

    @IBOutlet weak var extendedHeader: UILabel!
    @IBOutlet weak var extendedValue: UITextField!

    @IBOutlet weak var exemptionHeader: UILabel!
    @IBOutlet weak var exemptionValue: UITextField!
    
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    
    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: functions
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        style()
        autoFill()
    }

    func autoFill() {
        if let start = rup.planStartDate {
            planStartValue.text = start.string()
        }

        if let end = rup.planEndDate {
            planEndValue.text = end.string()
        }
    }

    // MARK: Styles
    func style() {
        styleDivider(divider: divider)
        styleSubHeader(label: header)
        styleFields()
    }

    func styleFields() {
        styleInputField(field: planStartValue, header: planStartHeader, height: fieldHeight)
        styleInputField(field: planEndValue, header: planEndHeader, height: fieldHeight)
        styleInputField(field: exemptionValue, header: exemptionHeader, height: fieldHeight)
        styleInputField(field: extendedValue, header: extendedHeader, height: fieldHeight)
    }
    
}
