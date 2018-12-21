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
import DatePicker

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

    @IBOutlet weak var actionDropDown: UIButton!

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
        optionsVC.setup(options: options, onVC: parent, onButton: sender) { (option) in
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
    }

    @IBAction func actionFieldAction(_ sender: UIButton) {
        guard let current = action, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: Options.shared.getPastureActionLookup(), onVC: parent, onButton: actionDropDown) { (selected, selection) in
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
    }

    @IBAction func noGrazePeriodBegin(_ sender: UIButton) {
        guard let parent = self.parentReference else {return}

        let minMonth = 1
        let minDay = 1
        let picker = DatePicker()
        picker.setupYearless(minMonth: minMonth, minDay: minDay) { (selected, month, day) in
            if selected, let month = month, let day = day {
                self.handleNoGrazeIn(month: month, day: day)
            }
        }
        picker.displayPopOver(on: sender, in: parent) {}
    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {
        guard let parent = self.parentReference, let action = self.action else {return}

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

        picker.displayPopOver(on: sender, in: parent) {}
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
        autoFill()
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
        autoFill()
    }

//    func handleDateIn(date: Date) {
//        guard let act = self.action else {return}
//        do {
//            let realm = try Realm()
//            try realm.write {
//                act.noGrazeDateIn = date
//            }
//        } catch _ {
//            fatalError()
//        }
//
//        if let dateOut = act.noGrazeDateOut {
//            if dateOut < date {
//                do {
//                    let realm = try Realm()
//                    try realm.write {
//                        act.noGrazeDateOut = date
//                    }
//                } catch _ {
//                    fatalError()
//                }
//            }
//        }
//
//        autoFill()
//    }
//
//    func handleDateOut(date: Date) {
//        guard let act = self.action else {return}
//        do {
//            let realm = try Realm()
//            try realm.write {
//                act.noGrazeDateOut = date
//            }
//        } catch _ {
//            fatalError()
//        }
//
//        autoFill()
//    }

    func deletePastureActions() {
        
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
        if self.mode == .Edit, current.details.isEmpty {
            setPlaceHolder()
        }

        if current.noGrazeInSelected {
            self.noGrazeIn.text = "\(DatePickerHelper.shared.month(number: current.noGrazeInMonth)) \(current.noGrazeInDay)"
        } else {
            self.noGrazeIn.text = ""
        }

        if current.noGrazeOutSelected {
            self.noGrazeOut.text = "\(DatePickerHelper.shared.month(number: current.noGrazeOutMonth)) \(current.noGrazeOutDay)"
        } else {
            self.noGrazeOut.text = ""
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
            if isPlaceHolder(text: descriptionField.text) {
                descriptionField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        if isPlaceHolder(text: textView.text) {
            removePlaceHolder()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let act = self.action, let text = textView.text else {return}

        if !isPlaceHolder(text: textView.text) {
            do {
                let realm = try Realm()
                try realm.write {
                    act.details = text
                }
            } catch _ {
                fatalError()
            }
        }

        if textView.text == "" {
            setPlaceHolder()
        }

    }

    /* Exact same functions found in MinistersIssueActionTableViewCell */
    func isPlaceHolder(text: String) -> Bool {
        switch text {
        case PlaceHolders.Actions.herding:
            return true
        case PlaceHolders.Actions.livestockVariables:
            return true
        case PlaceHolders.Actions.other:
            return true
        case PlaceHolders.Actions.salting:
            return true
        case PlaceHolders.Actions.timing:
            return true
        case PlaceHolders.Actions.supplementalFeeding:
            return true
        default:
            return false
        }
    }

    func getPlaceHolder(for option: String) -> String {
        switch option.lowercased() {
        case "herding":
            return PlaceHolders.Actions.herding
        case "livestock variables":
            return PlaceHolders.Actions.livestockVariables
        case "salting":
            return PlaceHolders.Actions.salting
        case "supplemental feeding":
            return PlaceHolders.Actions.supplementalFeeding
        case "timing":
            return PlaceHolders.Actions.timing
        case "":
            return ""
        default:
            return PlaceHolders.Actions.other
        }
    }

    func setPlaceHolder() {
        guard let action = self.action else {return}
        let placeholder: String = getPlaceHolder(for: action.action.lowercased())
        addPlaceHolder(string: placeholder)
    }

    func addPlaceHolder(string: String) {
        descriptionField.text = string
        descriptionField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder() {
        descriptionField.text = ""
        descriptionField.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
    }
}
