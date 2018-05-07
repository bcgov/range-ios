//
//  ScheduleTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleTableViewCell: BaseFormCell {

    // MARK: Variables
    let cellHeight = 56.5
    var parentReference: CreateNewRUPViewController?

    // MARK: Outlets
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    // MARK: Outlet Action
    @IBAction func addScheduleAction(_ sender: UIButton) {
        guard let p = parentReference,
            let start = rup.planStartDate,
            let end = rup.planEndDate
            else { return }
        let vm = ViewManager()
        let picker = vm.datePicker

        let taken = RUPManager.shared.getScheduleYears(rup: rup)

        picker.setup(for: start, max: end, taken: taken) { (selection) in
            if RUPManager.shared.isNewScheduleYearValidFor(rup: self.rup, newYear: Int(selection)!) {
                let schedule = Schedule()
                schedule.name = selection
                schedule.year = Int(selection)!

                do {
                    let realm = try Realm()
                    let aRup = realm.objects(RUP.self).filter("localId = %@", self.rup.localId).first!
                    try realm.write {
                        aRup.schedules.append(schedule)
                        realm.add(schedule)
                    }
                    self.rup = aRup
                } catch _ {
                    fatalError()
                }
                self.updateTableHeight()
                p.showSchedule(object: schedule, completion: { (done) in
                    
                })
            } else {
                p.showAlert(with: "Invalid year", message: "Please select a year within range of plan start and end dates")
            }
        }
        p.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    // MARK: Setup
    func setup(rup: RUP, parentReference: CreateNewRUPViewController) {
        self.parentReference = parentReference
        self.rup = rup
        tableHeight.constant = CGFloat( Double(rup.schedules.count) * cellHeight + 5.0)
        setUpTable()
        style()
    }

    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        styleHollowButton(button: addButton)
        styleContainer(layer: tableView.layer)
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        let count = rup.schedules.count
        tableHeight.constant = CGFloat( Double(count) * cellHeight + 5.0)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTo(indexPath: parent.scheduleIndexPath)
    }
    
}

// MARK: Tableview
extension ScheduleTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleCellTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleCell(indexPath: IndexPath) -> ScheduleCellTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleCellTableViewCell", for: indexPath) as! ScheduleCellTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rup.schedules.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getScheduleCell(indexPath: indexPath)
        cell.setup(rup: rup, schedule: (rup.schedules.sorted(by: { $0.year < $1.year })[indexPath.row]), parentReference: self)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}
