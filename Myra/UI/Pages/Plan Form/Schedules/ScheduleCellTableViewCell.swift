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
    var realmNotificationToken: NotificationToken?
    
    // MARK: Outlets
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var optionsIcon: UIView!
    
    // MARK: Outlet Actions
    @IBAction func optionsAction(_ sender: Any) {
        showOptions()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleBasedOnValidity()
    }
    
    @IBAction func detailAction(_ sender: Any) {
        guard let schedule = self.schedule, let plan = self.plan, let presenter = getPresenter() else {return}
        presenter.showScheduleDetails(for: schedule, in: plan, mode: mode)
    }
    
    // MAKR: Notifications
    
    func setupListeners() {
        beginChangeListener()
        NotificationCenter.default.addObserver(self, selector: #selector(planChanged), name: .planChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(planClosed), name: .planClosed, object: nil)
    }
    
    @objc func planClosed(_ notification: Notification) {
       NotificationCenter.default.removeObserver(self)
    }
    
    @objc func planChanged(_ notification: Notification) {
        if let sched = self.schedule {
            Logger.log(message: "Plan Object change notifcation received in Schedule: \(sched.year)")
        } else {
            Logger.log(message: "Plan Object change notifcation received in Schedule: UNKNOWN")
        }
        styleBasedOnValidity()
    }
    
    func beginChangeListener() {
        guard let schedule = self.schedule else { return }
        self.realmNotificationToken = schedule.observe { (change) in
            switch change {
            case .error:
                Logger.log(message: "Error in schedule \(schedule.year) change.")
            case .change:
                Logger.log(message: "Change observed in schedule \(schedule.year).")
                NotificationCenter.default.post(name: .planChanged, object: nil)
            case .deleted:
                //Logger.log(message: "Plan \(schedule.year) deleted.")
                self.endChangeListener()
            }
        }
    }
    
    func endChangeListener() {
        NotificationCenter.default.removeObserver(self)
        if let token = self.realmNotificationToken {
            token.invalidate()
            Logger.log(message: "Stopped Listening to Changes in Schedule :(")
        }
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
            Alert.show(title: "Are you sure?", message: "Deleting the \(s.year) schedule will also delete all of its entries", yes: {
                Logger.log(message: "Deleting \(s.year) Schedule")
                self.endChangeListener()
                RealmRequests.deleteObject(s)
                p.updateTableHeight()
            }) {}
        }
    }
    
    func duplicate() {
        guard let sched = schedule, let plan  = self.plan, let parent = parentReference else {return}
        let vm = ViewManager()
        let picker = vm.datePicker
        let taken = RUPManager.shared.getScheduleYears(rup: plan)
        guard let start = plan.planStartDate, let end = plan.planEndDate else { return }
        picker.setup(for: start, max: end, taken: taken) { (selection) in
            guard let year = Int(selection) else {return}
            let copy = Schedule()
            copy.year = year
            copy.notes = sched.notes
            RUPManager.shared.copyScheduleObjects(from: sched, to: copy)
            do {
                let realm = try Realm()
                if let aRup = realm.objects(Plan.self).filter("localId = %@", plan.localId).first {
                    try realm.write {
                        aRup.schedules.append(copy)
                        realm.add(copy)
                    }
                    self.plan = aRup
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
            parent.updateTableHeight()
        }
        parent.parentReference?.showPopOver(on: optionsButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }
    
    // MARK: Setup
    func setup(mode: FormMode, plan: Plan, schedule: Schedule, parentReference: ScheduleTableViewCell) {
        self.schedule = schedule
        if nameLabel != nil { nameLabel.text = schedule.yearString }
        self.parentReference = parentReference
        self.plan = plan
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
        setupListeners()
    }
    
    // MARK: Styles
    func style() {
        roundCorners(layer: cellContainer.layer)
        addShadow(to: cellContainer.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 5)
        styleBasedOnValidity()
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
        guard let current = self.schedule, let plan = self.plan else {return}
        Logger.log(message: "Cheching validity of schedule \(current.year)")
        let valid = RUPManager.shared.validateSchedule(schedule: current, agreementID: plan.agreementId)
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
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
            if let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first {
                self.schedule = aSchedule
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }
}
