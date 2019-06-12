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
        guard let plan = self.plan, let parent = self.parentViewController as? CreateNewRUPViewController, let min = plan.agreementStartDate, let max = plan.agreementEndDate else {return}
        let picker = DatePicker()
        picker.setup(beginWith: plan.planStartDate, min: min, max: max) { (selected, date) in
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
        guard let plan = self.plan, let min = plan.agreementStartDate, let max = plan.agreementEndDate else {return}

        if let planStartDate = plan.planStartDate {
            guard let endOfFiveYearsLater = DatePickerHelper.shared.dateFrom(day: 31, month: 12, year: planStartDate.year() + 4) else {return}
             var maxEnd = endOfFiveYearsLater
            if maxEnd > max {
                maxEnd = max
            }

            picker.setup(beginWith: plan.planEndDate, min: planStartDate, max: maxEnd) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handlePlanEndDate(date: date)
                    }
                }
            }
        } else {
            picker.setup(beginWith: plan.planEndDate, min: min, max: max) { (selected, date) in
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

    // MARK: Date handlers
    func handlePlanStartDate(date: Date) {
        guard let plan = self.plan else {return}
        // Store
        plan.setPlanStartDate(to: date)

        // Check end date
        if let endDate = plan.planEndDate {
            let endYear = endDate.year()
            let startYear = date.year()
            if endDate < date || (endYear - startYear) > 5 {
                self.planEndValue.text = DateManager.toString(date: (plan.planStartDate)!)
                do {
                    let realm = try Realm()
                    try realm.write {
                        plan.planEndDate = plan.planStartDate
                    }
                } catch _ {
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
                }
            }
        }
        
        autoFill()

        reloadParentIfDatesAreSet()
    }

    func handlePlanEndDate(date: Date) {
        guard let plan = self.plan else {return}
        plan.setPlanEndDate(to: date)
        self.planEndValue.text = date.string()
        reloadParentIfDatesAreSet()
    }

    // this will load usage years
    func reloadParentIfDatesAreSet() {
        guard let plan = self.plan, let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        if !reloadingUsage {
            self.reloadingUsage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if plan.planStartDate != nil && plan.planEndDate != nil {
                    DispatchQueue.main.async {
                        parent.reload(at: .BasicInfo)
                    }
                }
                self.reloadingUsage = false
            }
        }
    }

    // MARK: Setup
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.plan = rup
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
        guard let plan = self.plan else {return}
        if let start = plan.planStartDate {
            planStartValue.text = start.string()
        }

        if let end = plan.planEndDate {
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
