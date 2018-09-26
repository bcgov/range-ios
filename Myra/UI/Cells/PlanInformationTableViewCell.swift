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
import DatePicker
import Extended

class PlanInformationTableViewCell: BaseFormCell {

    // MARK: Constants

    // MARK: Variables
    var reloadingUsage = false

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
        let picker = DatePicker()
        picker.setup(beginWith: rup.planStartDate, min: min, max: max) { (selected, date) in
            if let d = date {
                DispatchQueue.main.async {
                    self.handlePlanStartDate(date: d)
                }
            }
        }

        picker.displayPopOver(on: sender as! UIButton, in: parent, completion: {
            self.reloadParentIfDatesAreSet()
        })
    }

    @IBAction func planEndAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        let picker = DatePicker()
        guard let min = rup.agreementStartDate, let max = rup.agreementEndDate else {return}

        if rup.planStartDate != nil{
            let startDate = DateManager.from(string: planStartValue.text!)
            var maxEnd = DateManager.fiveYearsLater(date: startDate)
            if maxEnd > max {
                maxEnd = max
            }

            picker.setup(beginWith: rup.planEndDate, min: startDate, max: maxEnd) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handlePlanEndDate(date: date)
                    }
                }
            }
            
        } else {
            picker.setup(beginWith: rup.planEndDate, min: min, max: max) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handlePlanEndDate(date: date)
                    }
                }
            }
        }
        
        picker.displayPopOver(on: sender as! UIButton, in: parent, completion: {
            self.reloadParentIfDatesAreSet()
        })
    }

    // MARK: functions
    func handlePlanStartDate(date: Date) {
        // Store
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.planStartDate = date
            }
        } catch _ {
            fatalError()
        }

        // Check end date
        if let endDate = self.rup.planEndDate {
            let endYear = endDate.year()
            let startYear = date.year()
            if endDate < date || (endYear - startYear) > 5 {
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

        // fill date fields
        if let start = self.rup.planStartDate {
            self.planStartValue.text = start.string()
        }

        if let end = self.rup.planEndDate {
            self.planEndValue.text = end.string()
        }

        reloadParentIfDatesAreSet()
    }

    func handlePlanEndDate(date: Date) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.planEndDate = date
            }
        } catch _ {
            fatalError()
        }

        if let end = self.rup.planEndDate {
            self.planEndValue.text = end.string()
        }
        reloadParentIfDatesAreSet()
    }

    // this will load usage years
    func reloadParentIfDatesAreSet() {
        if !reloadingUsage {
            self.reloadingUsage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let parent = self.parentViewController as! CreateNewRUPViewController
                if let _ = self.rup.planStartDate, let _ = self.rup.planEndDate {
                    DispatchQueue.main.async {
                        parent.reload(at: parent.rangeUsageIndexPath)
                    }
                }
                self.reloadingUsage = false
            }
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
