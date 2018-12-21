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

    // MARK: Variables
    static let cellHeight = 66.5
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
    }

    @IBAction func detailAction(_ sender: Any) {
        if let schedule = self.schedule, let presenter = getPresenter() {
            presenter.showScheduleDetails(for: schedule, in: rup, mode: mode)
        }
//        guard let sched = self.schedule else {return}
//        // refenrece to create page.
//        let grandParent = self.parentViewController as! CreateNewRUPViewController
//        grandParent.showSchedule(object: sched, completion: { done in
//            self.styleBasedOnValidity()
//        })
    }

    // MARK: Options
    func showOptions() {
        guard let grandParent = self.parentViewController as? CreateNewRUPViewController else {return}
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Copy, display: "Copy"), Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: grandParent, onButton: optionsButton) { (option) in
            switch option.type {
            case .Delete:
                self.delete()
            case .Copy:
                self.duplicate()
            }
        }
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
                let aRup = realm.objects(Plan.self).filter("localId = %@", self.rup.localId).first!
                try realm.write {
                    aRup.schedules.append(copy)
                    realm.add(copy)
                }
                self.rup = aRup
            } catch _ {
                fatalError()
            }
            parent.updateTableHeight()
        }
        parent.parentReference?.showPopOver(on: optionsButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }
    
    // MARK: Setup
    func setup(mode: FormMode, rup: Plan, schedule: Schedule, parentReference: ScheduleTableViewCell) {
        self.schedule = schedule
        if nameLabel != nil { nameLabel.text = schedule.yearString }
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

    // MARK: Styles
    func style() {
        roundCorners(layer: cellContainer.layer)
        addShadow(to: cellContainer.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 5)
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
        refreshScheduleObject()
        guard let current = self.schedule else {return}
        let valid = RUPManager.shared.validateSchedule(schedule: current, agreementID: rup.agreementId)
        UIView.animate(withDuration: 0.2, animations: {
            if !valid.0 {
                self.styleInvalid()
            } else {
                self.styleValid()
            }
            self.layoutIfNeeded()
        })
    }

    func refreshScheduleObject() {
        guard let sched = self.schedule else {return}
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            self.schedule = aSchedule
        } catch _ {
            fatalError()
        }
    }
}
