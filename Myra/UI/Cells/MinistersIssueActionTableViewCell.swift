//
//  MinistersIssueActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-29.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MinistersIssueActionTableViewCell: BaseFormCell {

    // MARK: Constants
    static let cellHeight: CGFloat = 182

    // MARK: Variables
    var action: MinisterIssueAction?
    var parentCell: MinisterIssueTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var timingStack: UIStackView!
    @IBOutlet weak var noGrazePeriodLabel: UILabel!
    @IBOutlet weak var noGrazeIn: UITextField!
    @IBOutlet weak var noGrazeOut: UITextField!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var optionsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!

    // MARK: Outlet Actions
    @IBAction func optionsAction(_ sender: UIButton) {
        guard let a = self.action, let parent = self.parentCell else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: grandParent, onButton: sender) { (selected) in
            switch selected.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "", yesButtonTapped: {
                    parent.deleteAction(action: a)
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }
    }

    @IBAction func noGrazePeriodBegin(_ sender: UIButton) {
        guard let parent = self.parentCell, let act = self.action else {return}
        let plan = parent.rup
        let grandParent = self.parentViewController as! CreateNewRUPViewController

        guard let planStart = plan.planStartDate, let planEnd = plan.planEndDate else {
//            parent.showTempBanner(message: "Plan start and end dates have not been selected")
            return
        }

        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(min: planStart, max: planEnd) { (date) in
            self.handleDateIn(date: date)
        }
        grandParent.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {
        guard let parent = self.parentCell, let act = self.action else {return}
        let plan = parent.rup
        let grandParent = self.parentViewController as! CreateNewRUPViewController

        guard let planStart = plan.planStartDate, let planEnd = plan.planEndDate else {
//            parent.showTempBanner(message: "Plan start and end dates have not been selected")
            return
        }

        var min = planStart

        if let noGrazeIn = act.noGrazeDateIn {
            min = noGrazeIn
        }

        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(min: min, max: planEnd) { (date) in
            self.handleDateOut(date: date)
        }
        grandParent.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    func handleDateIn(date: Date) {
        guard let act = self.action else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.noGrazeDateIn = date
            }
        } catch _ {
            fatalError()
        }

        if let dateOut = act.noGrazeDateOut {
            if dateOut < date {
                do {
                    let realm = try Realm()
                    try realm.write {
                        act.noGrazeDateOut = date
                    }
                } catch _ {
                    fatalError()
                }
            }
        }

        autofill()
    }

    func handleDateOut(date: Date) {
        guard let act = self.action else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.noGrazeDateOut = date
            }
        } catch _ {
            fatalError()
        }

        autofill()
    }

    // MARK: Functions
    // MARK: Setup
    func setup(action: MinisterIssueAction, parentCell: MinisterIssueTableViewCell, mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        self.action = action
        self.parentCell = parentCell
        desc.delegate = self
        autofill()
        style()
    }

    func autofill() {
        guard let a = self.action else {return}
        self.desc.text = a.desc
        self.header.text = a.actionType
        if self.mode == .View {
            setDefaultValueIfEmpty(field: desc)
        }

        if let grazeIn = a.noGrazeDateIn {
            self.noGrazeIn.text =  grazeIn.string()
        } else {
            self.noGrazeIn.text = ""
        }

        if let grazeOut = a.noGrazeDateOut {
            self.noGrazeOut.text = grazeOut.string()
        } else {
            self.noGrazeOut.text = ""
        }

        if a.actionType.lowercased() == "timing" {
            timingStack.alpha = 1
        } else {
            timingStack.alpha = 0
        }

        animateIt()
    }

    // MARK: Style
    func style() {
        guard let _ = self.container else {return}
        styleContainer(view: container)
        switch self.mode {
        case .View:
            optionsButton.alpha = 0
            styleInputFieldReadOnly(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputFieldReadOnly(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: desc, header: header)
            optionsButtonWidth.constant = 0
        case .Edit:
            styleInputField(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputField(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputField(field: desc, header: header)
        }
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }

    // MARK: Utilities
    func duplicate() {

    }
}

// MARK: TextView delegates
extension MinistersIssueActionTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let a = action else {return}
        a.set(desc: textView.text)
    }
}
