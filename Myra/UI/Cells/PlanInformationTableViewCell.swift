//
//  PlanInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-24.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

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
    
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var startDateButton: UIButton!

    // MARK: Outlet actions
    @IBAction func planStartAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        guard let min = rup.agreementStartDate, let max = rup.agreementEndDate else {return}
        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(between: min, max: max) { (date) in
            self.handlePlanStartDate(date: date)
        }
        parent.showPopOver(on: sender as! UIButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    @IBAction func planEndAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let picker = vm.datePicker
        guard let min = rup.agreementStartDate, let max = rup.agreementEndDate else {return}
        if planStartValue.text != "" {

            let startDate = DateManager.from(string: planStartValue.text!)
            picker.setup(between: startDate, max: max) { (date) in
                self.handlePlanEndDate(date: date)
            }
        } else {
            picker.setup(between: min, max: max) { (date) in
                self.handlePlanEndDate(date: date)
            }
        }
        parent.showPopOver(on: sender as! UIButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }


    // MARK: functions
    func handlePlanStartDate(date: Date) {
        self.planStartValue.text = date.string()
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.planStartDate = date
            }
        } catch _ {
            fatalError()
        }
        if self.planEndValue.text != "" {
            let endDate = DateManager.from(string: self.planEndValue.text!)
            if endDate < date {
                self.planEndValue.text = DateManager.toString(date: (self.rup.planStartDate)!)
                do {
                    let realm = try Realm()
                    try realm.write {
                        self.rup.planEndDate = self.rup.planStartDate
                    }
                } catch _ {
                    fatalError()
                }
            }
        }
    }

    func handlePlanEndDate(date: Date) {
        self.planEndValue.text = date.string()
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.planEndDate = date
            }
        } catch _ {
            fatalError()
        }
    }

    // MARK: Setup
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        switch mode {
        case .View:
            startDateButton.isEnabled = false
            endDateButton.isEnabled = false
        case .Edit:
            startDateButton.isEnabled = true
            endDateButton.isEnabled = true
        }
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
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: planStartValue, header: planStartHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: planEndValue, header: planEndHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: exemptionValue, header: exemptionHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: extendedValue, header: extendedHeader, height: fieldHeight)
        case .Edit:
            styleInputField(field: planStartValue, header: planStartHeader, height: fieldHeight)
            styleInputField(field: planEndValue, header: planEndHeader, height: fieldHeight)
            styleInputField(field: exemptionValue, header: exemptionHeader, height: fieldHeight)
            styleInputField(field: extendedValue, header: extendedHeader, height: fieldHeight)
        }
    }
    
}
