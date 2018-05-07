//
//  ScheduleFormTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleFormTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 55.0

    // Mark: Variables
    var schedule: Schedule?
    var rup: RUP?
    var parentReference: ScheduleViewController?

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var height: NSLayoutConstraint!

    @IBOutlet weak var pasture: UILabel!
    @IBOutlet weak var livestock: UILabel!
    @IBOutlet weak var numAnimals: UILabel!
    @IBOutlet weak var dateIn: UILabel!
    @IBOutlet weak var dateOut: UILabel!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var graceDays: UILabel!
    @IBOutlet weak var PLD: UILabel!
    @IBOutlet weak var crownAUMs: UILabel!
    @IBOutlet weak var addButton: UIButton!

    // Mark: Outlet Actions
    @IBAction func addAction(_ sender: Any) {
        createEntry(from: nil)
    }

    // Mark: Functions
    func createEntry(from: ScheduleObject?) {
        guard let sched = self.schedule else {return}
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            if let copyFrom = from {
                RUPManager.shared.copyScheduleObject(fromObject: copyFrom, inSchedule: aSchedule)
            } else {
                try realm.write {
                    let new = ScheduleObject()
                    aSchedule.scheduleObjects.append(new)
                    realm.add(new)
                }
            }
            self.schedule = aSchedule
        } catch _ {
            fatalError()
        }
        // todo: Remove?
        parentReference?.calculateTotals()

        updateTableHeight()
    }

    func deleteEntry(object: ScheduleObject) {
        guard let sched = self.schedule else {return}
        RealmRequests.deleteObject(object)
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            self.schedule = aSchedule
        } catch _ {
            fatalError()
        }

        updateTableHeight()
    }

    // MARK: Setup
    func setup(schedule: Schedule, rup: RUP, parentReference: ScheduleViewController) {
        self.parentReference = parentReference
        self.rup = rup
        self.schedule = schedule
        height.constant = CGFloat( Double((schedule.scheduleObjects.count)) * ScheduleFormTableViewCell.cellHeight + 5.0)
        setUpTable()
        style()
    }

    func updateTableHeight() {
        self.tableView.reloadData()
        height.constant = CGFloat( Double((schedule?.scheduleObjects.count)!) * ScheduleFormTableViewCell.cellHeight + 5.0)
        let parent = self.parentViewController as! ScheduleViewController
        parent.reloadCells()
    }

    // MARK: Styles
    func style() {
        styleFieldHeader(label: pasture)
        styleFieldHeader(label: livestock)
        styleFieldHeader(label: numAnimals)
        styleFieldHeader(label: dateIn)
        styleFieldHeader(label: dateOut)
        styleFieldHeader(label: days)
        styleFieldHeader(label: graceDays)
        styleFieldHeader(label: PLD)
        styleFieldHeader(label: crownAUMs)
        styleHollowButton(button: addButton)
    }
    
}

extension ScheduleFormTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleObjectTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleObjectCell(indexPath: IndexPath) -> ScheduleObjectTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleObjectTableViewCell", for: indexPath) as! ScheduleObjectTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getScheduleObjectCell(indexPath: indexPath)
        if let object = schedule?.scheduleObjects[indexPath.row], let r = self.rup, let schedRef = parentReference {
            cell.setup(scheduleObject: object, rup: r, scheduleViewReference: schedRef, parentCell: self)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule?.scheduleObjects.count ?? 0
    }

}
