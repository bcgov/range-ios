//
//  ScheduleObjectTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import DatePicker

class ScheduleObjectTableViewCell: BaseFormCell {

    // Mark: Constants
    static let cellHeight = 57.0
    // MARK: Variables
    var scheduleObject: ScheduleObject?
    var scheduleViewReference: ScheduleViewController?

    var inputFields: [UITextField] = [UITextField]()
    var computedFields: [UITextField] = [UITextField]()
    var fields: [UITextField] = [UITextField]()

    // MARK: Outlets
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var pasture: UITextField!
    @IBOutlet weak var liveStock: UITextField!
    @IBOutlet weak var numberOfAniamls: UITextField!
    @IBOutlet weak var dateIn: UITextField!
    @IBOutlet weak var dateOut: UITextField!
    @IBOutlet weak var days: UITextField!
    @IBOutlet weak var graceDays: UITextField!
    @IBOutlet weak var crownAUM: UITextField!
    @IBOutlet weak var pldAUM: UITextField!

    @IBOutlet weak var options: UIButton!
    @IBOutlet weak var pastureButton: UIButton!
    @IBOutlet weak var liveStockButton: UIButton!
    @IBOutlet weak var dateInButton: UIButton!
    @IBOutlet weak var dateOutButton: UIButton!

    // Dropdowns
    @IBOutlet weak var pastureDropDown: UIButton!
    @IBOutlet weak var liveStockDropDown: UIButton!

    // MARK: Outlet Acions
    @IBAction func editGraceDays(_ sender: UITextField) {
        guard let entry = scheduleObject, let text = sender.text else {return}
        if text.isInt {
            sender.textColor = UIColor.black
            do {
                let realm = try Realm()
                try realm.write {
                    // force unwrapped but we are checking that it is an int using isInt extention
                    entry.graceDays = Int(text)!
                }
            } catch _ {
                fatalError()
            }
            self.update()
        } else {
            sender.textColor = UIColor.red
            if let p = entry.pasture {
                do {
                    let realm = try Realm()
                    try realm.write {
                        entry.graceDays = p.graceDays
                    }
                } catch _ {
                    fatalError()
                }
                self.update()
            }
        }
    }

    @IBAction func lookupPastures(_ sender: Any) {
        guard let scheduleVC = self.scheduleViewReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: Options.shared.getPasturesLookup(rup: rup), onVC: scheduleVC, onButton: pastureDropDown) { (selected, obj) in
            if selected, let object = obj {
                // set This object's pasture object.
                // this function also update calculations for pld and crown fields
                RUPManager.shared.setPastureOn(scheduleObject: self.scheduleObject!, pastureName: object.value, rup: self.rup)

                self.update()
                // Clear sort headers
                scheduleVC.clearSort()
                // NOTE: you can use this if you want to sort on change
                // and highlight the cell that moved
                /*
                 // if current sorting on parent is set to this field's type
                 if self.parentCell?.currentSort == .Pasture {
                 // this will hightlight cell
                 self.scheduleObject?.setIsNew(to: true)
                 }
                */
                scheduleVC.hidepopup(vc: lookup)
                scheduleVC.dismissPopOver()
            } else {
                scheduleVC.dismissPopOver()
            }
        }
    }

    @IBAction func lookupLiveStockType(_ sender: Any) {
        guard let scheduleVC = self.scheduleViewReference, let object = self.scheduleObject else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        let objects = Reference.shared.getLiveStockTypeLookup()
        lookup.setup(objects: objects, onVC: scheduleVC, onButton: liveStockDropDown) { (selected, obj) in
            if selected {
                if let selectedType = obj {
                    let ls = Reference.shared.getLiveStockTypeObject(name: selectedType.display)
                    do {
                        let realm = try Realm()
                        try realm.write {
                            object.liveStockTypeId = ls.id
                            object.liveStockTypeName = selectedType.display
                        }
                    } catch _ {
                        fatalError()
                    }
                } else {
                    print("FOUND ERROR IN lookupLiveStockType()")
                }
                RealmRequests.updateObject(object)
                self.update()
                // Clear sort headers
                scheduleVC.clearSort()
                scheduleVC.hidepopup(vc: lookup)
            } else {
                scheduleVC.hidepopup(vc: lookup)
                self.update()
            }
        }
    }

    @IBAction func numberOfAnimalsChanged(_ sender: UITextField) {
        guard let scheduleVC = self.scheduleViewReference, let object = self.scheduleObject else {return}
        guard let curr = numberOfAniamls.text else {return}
        if (curr.isInt) {
            numberOfAniamls.textColor = UIColor.black
            do {
                let realm = try Realm()
                try realm.write {
                    object.numberOfAnimals = Int(curr)!
                }
            } catch _ {
                fatalError()
            }
        } else {
            numberOfAniamls.textColor = UIColor.red
            do {
                let realm = try Realm()
                try realm.write {
                    object.numberOfAnimals = 0
                }
                // if current sorting on parent is set to this field's type
                if scheduleVC.currentSort == .Number {
                    // this will hightlight cell
                    object.setIsNew(to: true)
                }
            } catch _ {
                fatalError()
            }
        }
    }

    @IBAction func numberOfAnimalsSelected(_ sender: UITextField) {
        guard let scheduleVC = self.scheduleViewReference else {return}
        scheduleVC.clearSort()
        update()
    }

    @IBAction func dateInAction(_ sender: Any) {
        dismissKeyboard()
        guard let scheduleVC = self.scheduleViewReference else {return}
        let picker = DatePicker()
        guard let sched = scheduleVC.schedule,
            let minDate = DatePickerHelper.shared.dateFrom(day: 1, month: 1, year: sched.year),
            let maxDate = DatePickerHelper.shared.dateFrom(day: 31, month: 12, year: sched.year) else {return}

        if let entry = self.scheduleObject, let dateIn = entry.dateIn {
            picker.setup(beginWith: dateIn, min: minDate, max: maxDate) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handleDateIn(date: date)
                    }
                }
            }
        } else {
            picker.setup(min: minDate, max: maxDate) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handleDateIn(date: date)
                    }
                }
            }
        }

        picker.displayPopOver(on: sender as! UIButton, in: scheduleVC, completion: {})

    }

    @IBAction func dateOutAction(_ sender: Any) {
        dismissKeyboard()
        guard let scheduleVC = self.scheduleViewReference else {return}
        guard let sched = scheduleVC.schedule,
            var minDate = DatePickerHelper.shared.dateFrom(day: 1, month: 1, year: sched.year),
            let maxDate = DatePickerHelper.shared.dateFrom(day: 31, month: 12, year: sched.year) else {return}
        let picker = DatePicker()
        if let entry = self.scheduleObject, let dateOut = entry.dateOut {
            picker.setup(beginWith: dateOut, min: minDate, max: maxDate) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handleDateOut(date: date)
                    }
                }
            }
        } else {
            if let s = scheduleObject, let startDate = s.dateIn {
                minDate = startDate
            }

            picker.setup(min: minDate, max: maxDate) { (selected, date) in
                if let date = date {
                    DispatchQueue.main.async {
                        self.handleDateOut(date: date)
                    }
                }
            }
        }

        picker.displayPopOver(on: sender as! UIButton, in: scheduleVC, completion: {})
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let scheduleVC = scheduleViewReference else {return}
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Copy, display: "Copy"), Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: scheduleVC, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                self.deleteEntry()
            case .Copy:
                self.copyEntry()
            }
        }
    }

    // MARK: UITextField Fix

    // for grace days
    @IBAction func highlightGraceDays(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    // for number of animals field
    @IBAction func highlightField(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @objc private func selectRange(sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }
    /////////////////////


    // MARK: Functions
    func deleteEntry() {
        self.highlightOn()
        guard let scheduleVC = self.scheduleViewReference, let entry = self.scheduleObject else {return}
        scheduleVC.showAlert(title: "Delete schedule entry?", description: "", yesButtonTapped: {
            self.hightlightOff()
            scheduleVC.deleteEntry(object: entry)
        }) {
            self.hightlightOff()
        }
    }

    func copyEntry() {
        guard let scheduleVC = self.scheduleViewReference, let entry = self.scheduleObject else {return}
        scheduleVC.createEntry(from: entry)
    }
    
    func handleDateIn(date: Date) {
        guard let so = scheduleObject else {return}
        self.dateIn.text = DateManager.toStringNoYear(date: date)
        do {
            let realm = try Realm()
            try realm.write {
                so.dateIn = date
            }

        } catch _ {
            fatalError()
        }

        if let endDate = so.dateOut {
            if endDate < date {
                self.dateOut.text =  DateManager.toStringNoYear(date: (self.scheduleObject?.dateIn)!)
                do {
                    let realm = try Realm()
                    try realm.write {
                        so.dateOut = so.dateIn
                    }
                } catch _ {
                    fatalError()
                }
                self.calculateDays()
                self.update()
            }
        } else {
            self.calculateDays()
            self.update()
        }
    }

    func handleDateOut(date: Date) {
        guard let so = scheduleObject else {return}
        self.dateOut.text = DateManager.toStringNoYear(date: date)
        do {
            let realm = try Realm()
            try realm.write {
                so.dateOut = date
            }
        } catch _ {
            fatalError()
        }
        DispatchQueue.main.async {
            self.calculateDays()
            self.update()
        }
    }

    // MARK: Style
    func style() {

        // Group fields, to call style functions iteratively.
        // note: numberOfAniamls is different from the rest: accepts input
        if inputFields.isEmpty {
            self.inputFields = [pasture, liveStock, dateIn, dateIn, dateOut, graceDays]
        }
        if computedFields.isEmpty {
            self.computedFields = [days, crownAUM, pldAUM]
        }
        if fields.isEmpty {
            fields.append(contentsOf: inputFields)
            fields.append(contentsOf: computedFields)
            fields.append(numberOfAniamls)
        }

        let fontSize: CGFloat = 12

        // First style using theme styles
        switch mode {
        case .View:
            for field in inputFields {
                styleInputReadOnly(input: field, height: fieldHeight)
            }

            // note: numberOfAniamls is different from the rest: accepts input
            styleInputField(field: numberOfAniamls, editable: false, height: fieldHeight)

        case .Edit:
            for field in inputFields {
                styleInput(input: field, height: fieldHeight)
            }

            // note: numberOfAniamls is different from the rest: accepts input
            styleInputField(field: numberOfAniamls, editable: true, height: fieldHeight)
        }

        // Computed fields look the same regardless of mode
        for field in computedFields {
            styleInputField(field: field, editable: false, height: fieldHeight)
        }

        // This cell needs smaller fonts, so change all fonts:
        for field in fields {
            field.font = Fonts.getPrimary(size: fontSize)
        }
    }

    func highlight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = Colors.secondary.withAlphaComponent(0.75)
            self.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundColor = UIColor.white
                    self.layoutIfNeeded()
                })
            })
        }
    }

    func highlightOn() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = Colors.secondary.withAlphaComponent(0.5)
            self.layoutIfNeeded()
        })
    }

    func hightlightOff() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.white
            self.layoutIfNeeded()
        })
    }

    // MARK: Setup
    func setup(mode: FormMode, scheduleObject: ScheduleObject, rup: Plan, scheduleViewReference: ScheduleViewController, parentCell: ScheduleFormTableViewCell) {
        self.rup = rup
        self.mode = mode
        self.scheduleObject = scheduleObject
        self.scheduleViewReference = scheduleViewReference
//        self.parentCell = parentCell
        autofill()
        style()
        if scheduleObject.isNew {
            highlight()
            scheduleObject.setIsNew(to: false)
        }

        switch mode {
        case .View:
            options.isEnabled = false
            options.alpha = 0
            pastureButton.isEnabled = false
            liveStockButton.isEnabled = false
            dateInButton.isEnabled = false
            dateOutButton.isEnabled = false
            numberOfAniamls.isUserInteractionEnabled = false
        case .Edit:
            options.isEnabled = true
            options.alpha = 1
            pastureButton.isEnabled = true
            liveStockButton.isEnabled = true
            dateInButton.isEnabled = true
            dateOutButton.isEnabled = true
            numberOfAniamls.isUserInteractionEnabled = true
        }
    }

    func setup(mode: FormMode, scheduleObject: ScheduleObject, rup: Plan, scheduleViewReference: ScheduleViewController) {
        self.rup = rup
        self.mode = mode
        self.scheduleObject = scheduleObject
        self.scheduleViewReference = scheduleViewReference
        autofill()
        style()
        if scheduleObject.isNew {
            highlight()
            scheduleObject.setIsNew(to: false)
        }

        switch mode {
        case .View:
            options.isEnabled = false
            options.alpha = 0
            pastureButton.isEnabled = false
            liveStockButton.isEnabled = false
            dateInButton.isEnabled = false
            dateOutButton.isEnabled = false
            numberOfAniamls.isUserInteractionEnabled = false
        case .Edit:
            options.isEnabled = true
            options.alpha = 1
            pastureButton.isEnabled = true
            liveStockButton.isEnabled = true
            dateInButton.isEnabled = true
            dateOutButton.isEnabled = true
            numberOfAniamls.isUserInteractionEnabled = true
        }
    }

    func validate() {
        if let scheduleVC = scheduleViewReference {
            scheduleVC.validate()
        }
    }

    public func dismissKeyboard() {
        if scheduleViewReference == nil { return }
        scheduleViewReference?.view.endEditing(true)
    }

    func autofill() {
//        calculate()
        guard let obj = scheduleObject else {
            pasture.text = ""
            liveStock.text = ""
            numberOfAniamls.text = ""
            dateIn.text = ""
            dateOut.text = ""
            days.text = ""
            graceDays.text = ""
            crownAUM.text = ""
            pldAUM.text = ""
            return
        }

        // fields that are not filled by user
        fillCurrentValues()

        let numOfAnimals = obj.numberOfAnimals
        if numOfAnimals != 0 {
            self.numberOfAniamls.text = "\(numOfAnimals)"
        } else {
            self.numberOfAniamls.text = ""
            self.days.text = ""
        }

        if let inDate = obj.dateIn {
            self.dateIn.text = DateManager.toStringNoYear(date: inDate)
        } else {
            self.dateIn.text = ""
            self.days.text = ""
        }

        if let outDate = obj.dateOut {
            self.dateOut.text = DateManager.toStringNoYear(date: outDate)
        } else {
            self.dateOut.text = ""
        }

        self.graceDays.text = "\(obj.graceDays)"

        calculateDays()
    }

    func calculate() {
        guard let object = self.scheduleObject else {return}
        object.calculateAUMsAndPLD()
    }

    // update calculations
    func update() {
        calculate()
        fillCurrentValues()
        validate()
        if let p = self.scheduleViewReference {
            p.autofillTotals()
        }
        return
    }

    func fillCurrentValues() {
        guard let entry = self.scheduleObject else {return}
        // Live Stock Type

        if entry.liveStockTypeId != -1 {
            let liveStockObject = Reference.shared.getLiveStockTypeObject(id: entry.liveStockTypeId)
            self.liveStock.text = liveStockObject.name

        } else {
            self.liveStock.text = ""
        }

        if let pasture = entry.pasture {
            self.pasture.text = pasture.name
        } else {
            self.pasture.text = ""
        }

        self.graceDays.text = "\(entry.graceDays)"
        self.pldAUM.text = "\(entry.pldAUMs.rounded())"
        self.crownAUM.text = "\(entry.getCrownAUMs().rounded())"
    }

    func calculateDays() {
        guard let s = scheduleObject, let din = s.dateIn, let dout = s.dateOut else {return}
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: din)
        let date2 = calendar.startOfDay(for: dout)
        let count = DateManager.daysBetween(date1: date1, date2: date2) + 1
        self.days.text = "\(String(describing: count))"
    }

    func disableTextFields() {
        // All fields except for number of animals whould not allow free text entry.
        // labels weren't used because at the time of creation, i had no idea what values
        // the fields should take.
        pasture.isUserInteractionEnabled = false
        liveStock.isUserInteractionEnabled = false
        dateIn.isUserInteractionEnabled = false
        dateOut.isUserInteractionEnabled = false
        days.isUserInteractionEnabled = false
        graceDays.isUserInteractionEnabled = false
        crownAUM.isUserInteractionEnabled = false
        pldAUM.isUserInteractionEnabled = false
    }
}
