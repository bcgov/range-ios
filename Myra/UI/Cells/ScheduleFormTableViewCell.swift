//
//  ScheduleFormTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleFormTableViewCell: UITableViewCell {

    let cellHeight = 50.0
    // Mark: Variables
    var schedule: Schedule?

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
        updateTableHeight()
    }

    // Mark: Functions
    func setup(schedule: Schedule) {
        self.schedule = schedule
        setUpTable()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()

        height.constant = CGFloat( Double((schedule?.scheduleObjects.count)!) * cellHeight + 5.0)

        let parent = self.parentViewController as! ScheduleViewController
        parent.tableView.reloadData()
    }
    
}

extension ScheduleFormTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleObjectTableViewCell")
        registerCell(name: "AgreementInformationTableViewCell")
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
            cell.setup(scheduleObject: object)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = schedule?.scheduleObjects.count {
            return count
        } else {
            return 0
        }
    }

}
