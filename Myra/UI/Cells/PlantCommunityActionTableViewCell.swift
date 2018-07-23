//
//  PlantCommunityActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityActionTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 255.0

    // MARK: Variables
    var mode: FormMode = .View
    var flag = false
    var action: PastureAction?
    var parentReference: PlantCommunityViewController?
    var parentCellReference: PlantCommunityPastureActionsTableViewCell?

    // MARK: Outlets
//    @IBOutlet weak var noGrazeSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var actionField: UITextField!
    @IBOutlet weak var actionHeader: UILabel!
    @IBOutlet weak var noGrazePeriodLabel: UILabel!
    @IBOutlet weak var noGrazeIn: UITextField!
    @IBOutlet weak var noGrazeOut: UITextField!

    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var noGrazeStack: UIStackView!
    @IBOutlet weak var noGrazeStackHeight: NSLayoutConstraint!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let act = self.action, let parent = self.parentReference, let parentCell = self.parentCellReference else {return}
        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options) { (option) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch option.type {
            case .Delete:
                parent.showAlert(title: "Confirmation", description: "Would you like to delete this pasture action?", yesButtonTapped: {
                    RealmManager.shared.deletePastureAction(object: act)
                    parentCell.updateTableHeight()
                }, noButtonTapped: {})
            case .Copy:
                print("copy not implemented")
            }
        }
        parent.showPopOver(on: sender , vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)
    }

    @IBAction func actionFieldAction(_ sender: UIButton) {
        guard let current = action, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: RUPManager.shared.getPastureActionLookup(), onVC: parent, onButton: sender) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        current.action = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
        /*
        lookup.setup(objects: RUPManager.shared.getPastureActionLookup()) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        current.action = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
        parent.showPopUp(vc: lookup, on: sender)
        */
    }

    @IBAction func noGrazePeriodBegin(_ sender: UIButton) {
        guard let parent = self.parentReference, let plan = parent.plan else {return}

        guard let planStart = plan.planStartDate, let planEnd = plan.planEndDate else {
            parent.showTempBanner(message: "Plan start and end dates have not been selected")
            return
        }

        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(between: planStart, max: planEnd) { (date) in
            self.handleDateIn(date: date)
        }
        parent.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {
        guard let parent = self.parentReference, let plan = parent.plan , let act = self.action else {return}

        guard let planStart = plan.planStartDate, let planEnd = plan.planEndDate else {
            parent.showTempBanner(message: "Plan start and end dates have not been selected")
            return
        }

        var min = planStart

        if let noGrazeIn = act.noGrazeDateIn {
            min = noGrazeIn
        }

        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(between: min, max: planEnd) { (date) in
            self.handleDateOut(date: date)
        }
        parent.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
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

        autoFill()
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

        autoFill()
    }

    // MARK: Setup
    func setup(mode: FormMode, action: PastureAction, parentReference: PlantCommunityViewController, parentCellRefenrece: PlantCommunityPastureActionsTableViewCell) {
        self.mode = mode
        self.action = action
        self.parentReference = parentReference
        self.parentCellReference = parentCellRefenrece
        style()
        autoFill()
        descriptionField.delegate = self
    }

    func autoFill() {
        guard let current = action else {return}
        self.actionField.text = current.action
        if current.action.lowercased() == "timing" {
            showNoGrazeSection()
        } else {
            hideNoGrazeSection()
        }

        self.descriptionField.text = current.details
        if let dateIn = current.noGrazeDateIn {
            self.noGrazeIn.text = dateIn.string()
        }

        if let dateOut = current.noGrazeDateOut {
            self.noGrazeOut.text = dateOut.string()
        }
    }

    func hideNoGrazeSection() {
        noGrazeStackHeight.constant = 0
        noGrazeStack.alpha = 0
        animateIt()
    }

    func showNoGrazeSection() {
        noGrazeStackHeight.constant = 55
        noGrazeStack.alpha = 1
        animateIt()
    }

    func animateIt() {
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
    }

    func style() {
//        styleFieldHeader(label: noGrazePeriodLabel)
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: actionField, header: actionHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputFieldReadOnly(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: descriptionField, header: descriptionHeader)
        case .Edit:
            styleInputField(field: actionField, header: actionHeader, height: inputFieldHeight)
            styleInputField(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputField(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputField(field: descriptionField, header: descriptionHeader)
        }
    }

    public func dismissKeyboard() {
        guard let parent = self.parentReference else { return }
        parent.view.endEditing(true)
    }
}

// MARK: Notes
extension PlantCommunityActionTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let act = self.action, let text = textView.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.details = text
            }
        } catch _ {
            fatalError()
        }
    }
}
