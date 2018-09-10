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
import DatePicker

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
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let minMonth = 1
        let minDay = 1
        let picker = DatePicker()
        
        picker.setupYearless(minMonth: minMonth, minDay: minDay) { (selected, month, day) in
            if selected, let month = month, let day = day {
                self.handleNoGrazeIn(month: month, day: day)
            }
        }
        picker.displayPopOver(on: sender, in: grandParent) {}
    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {
        guard let action = self.action else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController

        var minMonth = 1
        var minDay = 1

        if action.noGrazeInSelected {
            minMonth = action.noGrazeInMonth
            minDay = action.noGrazeInDay
        }

        let picker = DatePicker()

        picker.setupYearless(minMonth: minMonth, minDay: minDay) { (selected, month, day) in
            if selected, let month = month, let day = day {
                self.handleNoGrazeOut(month: month, day: day)
            }
        }

        picker.displayPopOver(on: sender, in: grandParent) {}
    }

    func handleNoGrazeIn(month: Int, day: Int) {
        guard let act = self.action else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.noGrazeInDay = day
                act.noGrazeInMonth = month
                act.noGrazeInSelected = true
            }
        } catch _ {
            fatalError()
        }

        if act.noGrazeOutSelected {
            if act.noGrazeOutMonth < act.noGrazeInMonth {
                do {
                    let realm = try Realm()
                    try realm.write {
                        act.noGrazeOutSelected = false
                    }
                } catch _ {
                    fatalError()
                }
            }
        }
        autofill()
    }

    func handleNoGrazeOut(month: Int, day: Int) {
        guard let act = self.action else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.noGrazeOutDay = day
                act.noGrazeOutMonth = month
                act.noGrazeOutSelected = true
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
        if a.noGrazeInSelected {
            self.noGrazeIn.text = "\(FDHelper.shared.month(number: a.noGrazeInMonth)) \(a.noGrazeInDay)"
        } else {
            self.noGrazeIn.text = ""
        }

        if a.noGrazeOutSelected {
             self.noGrazeOut.text = "\(FDHelper.shared.month(number: a.noGrazeOutMonth)) \(a.noGrazeOutDay)"
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
        roundCorners(layer: container.layer)
        addShadow(to: container.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 3)
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
