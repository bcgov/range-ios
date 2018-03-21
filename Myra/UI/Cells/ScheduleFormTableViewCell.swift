//
//  ScheduleFormTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleFormTableViewCell: UITableViewCell {

    // Mark: Constants
    let cellHeight = 50.0

    // Mark: Variables
    var schedule: Schedule?
    var rup: RUP?
    var parentReference: ScheduleViewController?

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var height: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Mark: Outlet Actions
    @IBAction func addAction(_ sender: Any) {
        schedule?.scheduleObjects.append(ScheduleObject())
        // todo: Remove?
        parentReference?.calculateTotals()
        
        updateTableHeight()
    }

    // Mark: Functions
    func setup(schedule: Schedule, rup: RUP, parentReference: ScheduleViewController) {
        self.parentReference = parentReference
        self.rup = rup
        self.schedule = schedule
        height.constant = CGFloat( Double((schedule.scheduleObjects.count)) * cellHeight + 5.0)
        setUpTable()

    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        height.constant = CGFloat( Double((schedule?.scheduleObjects.count)!) * cellHeight + 5.0)

        let parent = self.parentViewController as! ScheduleViewController
        parent.reloadCells()
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
        if let object = schedule?.scheduleObjects[indexPath.row] {
            cell.setup(scheduleObject: object, rup: rup!, scheduleViewReference: parentReference!)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule?.scheduleObjects.count ?? 0
    }

}
