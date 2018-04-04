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

class ScheduleCellTableViewCell: UITableViewCell {
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionsView: UIView!

    @IBOutlet weak var leadingOptions: NSLayoutConstraint!

    var schedule: Schedule?
    var rup: RUP?
    var parentReference: ScheduleTableViewCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func copyAtion(_ sender: Any) {
        duplicate()
    }

    func setup(rup: RUP, schedule: Schedule, parentReference: ScheduleTableViewCell) {
        self.schedule = schedule
        if nameLabel != nil { nameLabel.text = schedule.name }
        self.parentReference = parentReference
        self.rup = rup
        styleBasedOnValidity()
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeLeft.direction = .left
//        self.view.addGestureRecognizer(swipeLeft)
    }

    func styleBasedOnValidity() {
        if RUPManager.shared.isScheduleValid(schedule: schedule!, agreementID: (rup?.id)!) {
            styleValid()
        } else {
            styleInvalid()
        }
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {

    }

    func duplicate() {
        let copy = Schedule()
        copy.year = (schedule?.year)!
        copy.scheduleObjects = (schedule?.scheduleObjects)!
        if let rupObject = rup {
            copy.year = RUPManager.shared.getNextScheduleYearFor(from: copy.year, rup: rupObject)
            copy.name = "\(copy.year)"
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.rup?.schedules.append(copy)
            }
        } catch _ {
            fatalError()
        }

        parentReference?.updateTableHeight()
        self.leadingOptions.constant = 0
        animateIt()
    }
    
    @IBAction func optionsAction(_ sender: Any) {
        let width = optionsView.frame.width
        self.leadingOptions.constant = 0 - width
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
//        let width = optionsView.frame.width
        self.leadingOptions.constant = 0
        animateIt()
    }

    func style() {
        let layer = cellContainer
        layer?.layer.cornerRadius = 3
        layer?.layer.borderWidth = 1
        layer?.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1).cgColor
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
