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

class ScheduleTableViewCell: UITableViewCell {

    let cellHeight = 56.5
    var rup: RUP?
    var parentReference: CreateNewRUPViewController?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addScheduleAction(_ sender: UIButton) {
        guard let p = parentReference else { return }

        p.promptInput(title: "Schedule year", accept: .Year, taken: RUPManager.shared.getScheduleYears(rup: rup!)) { (done, name) in
            if done {
                if name.isInt, let year = Int(name), let r = self.rup {
                    // check if year is valid
                    if RUPManager.shared.isNewScheduleYearValidFor(rup: r, newYear: year) {
                        let schedule = Schedule()
                        schedule.name = name
                        schedule.year = year

                        do {
                            let realm = try Realm()
                            let aRup = realm.objects(RUP.self).filter("realmID = %@", r.realmID).first!
                            try realm.write {
                                aRup.schedules.append(schedule)
                                realm.add(schedule)
                            }
                            self.rup = aRup
                        } catch _ {
                            fatalError()
                        }
                        self.updateTableHeight()
                    } else {
                        p.showAlert(with: "Invalid year", message: "Please select a year within range of plan start and end dates")
                    }
                } else {
                    p.showAlert(with: "Invalid year", message: "")
                }
            }
        }
    }

    func setup(rup: RUP, parentReference: CreateNewRUPViewController) {
        self.parentReference = parentReference
        self.rup = rup
        tableHeight.constant = CGFloat( Double(rup.schedules.count) * cellHeight + 5.0)
        setUpTable()
        style()
    }

    func updateTableHeight() {
        
//        guard let plan = rup else {
//            fatalError()
//        }
//
//        rup.schedules.sorted("year", ascending: true)
//        if let plan = rup {
//            RUPManager.shared.sortSchedule(rup: plan)
//        }
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        let count = rup?.schedules.count ?? 0
        tableHeight.constant = CGFloat( Double(count) * cellHeight + 5.0)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.scheduleIndexPath)
    }

    func style() {
        let layer = tableView.layer
        layer.cornerRadius = 3
        layer.borderWidth = 1
        layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1).cgColor
    }
    
}

extension ScheduleTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
//        if rup == nil {return}
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
        return (rup?.schedules.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getScheduleCell(indexPath: indexPath)
        cell.setup(rup: rup!, schedule: (rup?.schedules.sorted(by: { $0.year < $1.year })[indexPath.row])!, parentReference: self)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("seleted")
//        let parent = self.parentViewController as! CreateNewRUPViewController
//        parent.showSchedule(object: (rup?.schedules[indexPath.row])!)
    }

}
