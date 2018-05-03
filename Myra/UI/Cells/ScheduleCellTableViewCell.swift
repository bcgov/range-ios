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
    var schedule: Schedule?
    var parentReference: ScheduleTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionsView: UIView!

    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var leadingOptions: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func copyAtion(_ sender: Any) {
        duplicate()
    }

    @IBAction func deleteAction(_ sender: Any) {
        if let s = schedule, let p = parentReference {
            RealmRequests.deleteObject(s)
            p.updateTableHeight()
            self.leadingOptions.constant = 0
            animateIt()
        }
    }

    func setup(rup: RUP, schedule: Schedule, parentReference: ScheduleTableViewCell) {
        self.schedule = schedule
        if nameLabel != nil { nameLabel.text = schedule.name }
        self.parentReference = parentReference
        self.rup = rup
        style()
        styleBasedOnValidity()
    }

    override func orientationChanged(_ notification: NSNotification) {
        closeOptions("")
    }

    func styleBasedOnValidity() {
        if RUPManager.shared.isScheduleValid(schedule: schedule!, agreementID: (rup.agreementId)) {
            styleValid()
        } else {
            styleInvalid()
        }
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {    }

    func duplicate() {
        guard let sched = schedule else {return}
        let vm = ViewManager()
        let picker = vm.datePicker
        let taken = RUPManager.shared.getScheduleYears(rup: rup)
        guard let start = rup.planStartDate, let end = rup.planEndDate else { return }
        picker.setup(for: start, max: end, taken: taken) { (selection) in
            guard let year = Int(selection) else {return}
            let copy = Schedule()
            copy.year = year
            copy.name = selection
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
            self.leadingOptions.constant = 0
            self.animateIt()
        }
        parentReference?.parentReference?.showPopOver(on: copyButton, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }
    
    @IBAction func optionsAction(_ sender: Any) {
        self.leadingOptions.constant = 0 - optionsView.frame.width
        animateIt()
    }

    @IBAction func detailAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.showSchedule(object: schedule!, completion: { done in
            self.styleBasedOnValidity()
        })
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }

    @IBAction func closeOptions(_ sender: Any) {
        self.leadingOptions.constant = 0
        animateIt()
    }

    func style() {
        styleContainer(view: cellContainer)
        styleHollowButton(button: deleteButton)
        styleHollowButton(button: copyButton)
    }

    func styleInvalid() {
        nameLabel.textColor = UIColor.red
        cellContainer.layer.borderColor = UIColor.red.cgColor
    }
    func styleValid() {
        nameLabel.textColor = UIColor.black
        cellContainer.layer.borderColor = UIColor.black.cgColor
    }
}
