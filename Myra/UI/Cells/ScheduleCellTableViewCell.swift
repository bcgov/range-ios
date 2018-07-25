//
//  ScheduleCellTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleCellTableViewCell: BaseFormCell {

    // MARK: Constants
    static let cellHeight = 56.5

    // MARK: Variables
    var schedule: Schedule?
    var parentReference: ScheduleTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var optionsButton: UIButton!

    @IBOutlet weak var optionsIcon: UIView!

    // MARK: Outlet Actions
    @IBAction func optionsAction(_ sender: Any) {
        showOptions()
//        self.leadingOptions.constant = 0 - optionsView.frame.width
//        animateIt()
    }

    @IBAction func closeOptions(_ sender: Any) {
        animateIt()
    }

    @IBAction func detailAction(_ sender: Any) {
        guard let sched = self.schedule else {return}
        // refenrece to create page.
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        grandParent.showSchedule(object: sched, completion: { done in
            self.styleBasedOnValidity()
        })
    }

    // MARK: Functions
    func showOptions() {
        // refenrece to create page.
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Copy, display: "Copy"), Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options) { (selected) in
            optionsVC.dismiss(animated: false, completion: nil)
            switch selected.type {
            case .Delete:
                self.delete()
            case .Copy:
                self.duplicate()
            }
        }
        grandParent.showPopOver(on: optionsButton, vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)
    }

    func delete() {
        if let s = schedule, let p = parentReference {
            let grandParent = self.parentViewController as! CreateNewRUPViewController
            grandParent.showAlert(title: "Are you sure?", description: "Deleting the \(s.year) schedule will also delete all of its entries", yesButtonTapped: {
                RealmRequests.deleteObject(s)
                p.updateTableHeight()
            }) {}
        }
    }

    func duplicate() {
        guard let sched = schedule, let parent = parentReference else {return}
        let vm = ViewManager()
        let picker = vm.datePicker
        let taken = RUPManager.shared.getScheduleYears(rup: rup)
        guard let start = rup.planStartDate, let end = rup.planEndDate else { return }
        picker.setup(for: start, max: end, taken: taken) { (selection) in
            guard let year = Int(selection) else {return}
            let copy = Schedule()
            copy.year = year
            copy.notes = sched.notes
            RUPManager.shared.copyScheduleObjects(from: sched, to: copy)
            do {
                let realm = try Realm()
                let aRup = realm.objects(RUP.self).filter("localId = %@", self.rup.localId).first!
                try realm.write {
                    aRup.schedules.append(copy)
                    realm.add(copy)
                }
                self.rup = aRup
            } catch _ {
                fatalError()
            }
            self.parentReference?.updateTableHeight()
            self.animateIt()
        }
        parent.parentReference?.showPopOver(on: optionsButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }
    
    // MARK: Setup
    func setup(mode: FormMode, rup: RUP, schedule: Schedule, parentReference: ScheduleTableViewCell) {
        self.schedule = schedule
        if nameLabel != nil { nameLabel.text = schedule.name }
        self.parentReference = parentReference
        self.rup = rup
        self.mode = mode
        switch mode {
        case .View:
            optionsIcon.alpha = 0
            optionsButton.alpha = 0
            optionsButton.isEnabled = false
        case .Edit:
            optionsIcon.alpha = 1
            optionsButton.alpha = 1
            optionsButton.isEnabled = true
        }
        style()
        styleBasedOnValidity()
    }

    override func orientationChanged(_ notification: NSNotification) {
        closeOptions("")
    }

    // MARK: Styles
    func style() {
        styleContainer(view: cellContainer)
    }

    func styleInvalid() {
        nameLabel.textColor = UIColor.red
        cellContainer.layer.borderColor = UIColor.red.cgColor
    }
    func styleValid() {
        nameLabel.textColor = UIColor.black
        cellContainer.layer.borderColor = UIColor.black.cgColor
    }

    func styleBasedOnValidity() {
        if RUPManager.shared.isScheduleValid(schedule: schedule!, agreementID: (rup.agreementId)) {
            styleValid()
        } else {
            styleInvalid()
        }
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }
}
