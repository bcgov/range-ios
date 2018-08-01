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

class ScheduleObjectTableViewCell: BaseFormCell {

    // Mark: Constants
    static let cellHeight = 57.0
    // MARK: Variables
    var scheduleObject: ScheduleObject?
    var parentCell: ScheduleFormTableViewCell?
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

    // MARK: Outlet Acions

    @IBAction func editGraceDays(_ sender: UITextField) {
        guard let entry = scheduleObject, let text = sender.text else {return}
        if text.isInt {
            sender.textColor = UIColor.black
            do {
                let realm = try Realm()
                try realm.write {
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
        guard let parent = parentCell else {return}
        let button = sender as! UIButton
        let grandParent = self.parentViewController as! ScheduleViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: RUPManager.shared.getPasturesLookup(rup: rup), onVC: grandParent, onButton: button) { (selected, obj) in
            if selected, let object = obj {
                // set This object's pasture object.
                // this function also update calculations for pld and crown fields
                RUPManager.shared.setPastureOn(scheduleObject: self.scheduleObject!, pastureName: object.value, rup: self.rup)

                self.update()
                // Clear sort headers
                parent.clearSort()
                // NOTE: you can simply use this if you want to sort on change
                // and highlight the cell that moved
                /*
                 // if current sorting on parent is set to this field's type
                 if self.parentCell?.currentSort == .Pasture {
                 // this will hightlight cell
                 self.scheduleObject?.setIsNew(to: true)
                 }
                */
                grandParent.hidepopup(vc: lookup)
                grandParent.dismissPopOver()
            } else {
                grandParent.dismissPopOver()
            }
        }
    }

    @IBAction func lookupLiveStockType(_ sender: Any) {
        guard let parent = parentCell, let object = self.scheduleObject else {return}
        let button = sender as! UIButton
        let grandParent = self.parentViewController as! ScheduleViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let objects = RealmManager.shared.getLiveStockTypeLookup()
        lookup.setup(objects: objects, onVC: grandParent, onButton: button) { (selected, obj) in
            if selected {
                if let selectedType = obj {
                    let ls = RealmManager.shared.getLiveStockTypeObject(name: selectedType.display)
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
                parent.clearSort()
                grandParent.hidepopup(vc: lookup)
            } else {
                grandParent.hidepopup(vc: lookup)
                self.update()
            }
        }
    }

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

    @IBAction func numberOfAnimalsChanged(_ sender: UITextField) {
        guard let parent = parentCell, let object = self.scheduleObject else {return}
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
                if parent.currentSort == .Number {
                    // this will hightlight cell
                    object.setIsNew(to: true)
                }
            } catch _ {
                fatalError()
            }
        }
    }

    @IBAction func numberOfAnimalsSelected(_ sender: UITextField) {
        // Clear sort headers
        self.parentCell?.clearSort()
        update()
    }

    @IBAction func dateInAction(_ sender: Any) {
        dismissKeyboard()
        let grandParent = self.parentViewController as! ScheduleViewController

        let vm = ViewManager()
        let picker = vm.datePicker

        picker.setup(for: (grandParent.schedule?.year)!, minDate: nil) { (date) in
            self.handleDateIn(date: date)
            // Clear sort headers
            self.parentCell?.clearSort()
        }
        grandParent.showPopOver(on: sender as! UIButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    @IBAction func dateOutAction(_ sender: Any) {
        dismissKeyboard()
        let grandParent = self.parentViewController as! ScheduleViewController
        let vm = ViewManager()
        let picker = vm.datePicker

        if let s = scheduleObject, let startDate = s.dateIn {
            picker.setup(for: (grandParent.schedule?.year)!, minDate: startDate) { (date) in
                self.handleDateOut(date: date)
                // Clear sort headers
                if let parent = self.parentCell {
                    parent.clearSort()
                }
            }
        } else {
            picker.setup(for: (grandParent.schedule?.year)!, minDate: nil) { (date) in
                self.handleDateOut(date: date)
                // Clear sort headers
                if let parent = self.parentCell {
                    parent.clearSort()
                }
            }
        }
        grandParent.showPopOver(on: sender as! UIButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let grandParent = scheduleViewReference else {return}
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Copy, display: "Copy"), Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: grandParent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                self.deleteEntry()
            case .Copy:
                self.copyEntry()
            }
        }
    }


    // MARK: Functions
    func deleteEntry() {
        self.highlightOn()
        if let current = self.scheduleObject, let parent = self.parentCell, let grandParent = scheduleViewReference {
            grandParent.showAlert(title: "Delete schedule entry?", description: "", yesButtonTapped: {
                self.hightlightOff()
                parent.deleteEntry(object: current)
            }) {
                self.hightlightOff()
            }
        }
    }

    func copyEntry() {
        if let current = self.scheduleObject, let parent = self.parentCell {
            parent.createEntry(from: current)
        }
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

        self.calculateDays()
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
            }
        }
    }

    func handleDateOut(date: Date) {
        self.dateOut.text = DateManager.toStringNoYear(date: date)
        do {
            let realm = try Realm()
            try realm.write {
                self.scheduleObject?.dateOut = date
            }
        } catch _ {
            fatalError()
        }
        self.calculateDays()
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
    func setup(mode: FormMode, scheduleObject: ScheduleObject, rup: RUP, scheduleViewReference: ScheduleViewController, parentCell: ScheduleFormTableViewCell) {
        self.rup = rup
        self.mode = mode
        self.scheduleObject = scheduleObject
        self.scheduleViewReference = scheduleViewReference
        self.parentCell = parentCell
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
        calculate()
        guard let obj = scheduleObject else {
            return
        }

        // fields that are not filled by user
        fillCurrentValues()

        let numOfAnimals = obj.numberOfAnimals
        if numOfAnimals != 0 {
            self.numberOfAniamls.text = "\(numOfAnimals)"
        } else {
            self.numberOfAniamls.text = ""
        }

        if let inDate = obj.dateIn {
            self.dateIn.text = DateManager.toStringNoYear(date: inDate)
        } else {
            self.dateIn.text = ""
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
        RUPManager.shared.calculateScheduleEntry(scheduleObject: (object))
    }

    // update calculations
    func update() {
        calculate()
        fillCurrentValues()
        validate()
        if let p = self.scheduleViewReference {
            p.autofillResults()
        }
        return
    }

    func fillCurrentValues() {
        if scheduleObject == nil {return}

        // Live Stock Type
        if let liveStockId = scheduleObject?.liveStockTypeId, liveStockId != -1 {
            let liveStockObject = RealmManager.shared.getLiveStockTypeObject(id: liveStockId)
            self.liveStock.text = liveStockObject.name

        } else {
            self.liveStock.text = ""
            print("POSSIBLE ERROR IN fillCurrentValues() -> NO LIVESTOCK FOR CURRENT OBJECT")
        }

        if let pasture = scheduleObject?.pasture {
            self.pasture.text = pasture.name
        } else {
            self.pasture.text = ""
        }

        self.graceDays.text = "\(self.scheduleObject?.graceDays ?? 0)"
        self.pldAUM.text = "\(self.scheduleObject?.pldAUMs.rounded() ?? 0)"
        self.crownAUM.text = "\(self.scheduleObject?.crownAUMs.rounded() ?? 0.0)"
    }

    func calculateDays() {
        guard let s = scheduleObject, let din = s.dateIn, let dout = s.dateOut else {return}
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: din)
        let date2 = calendar.startOfDay(for: dout)
        self.days.text = "\(String(describing: DateManager.daysBetween(date1: date1, date2: date2)))"
        update()
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
