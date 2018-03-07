//
//  ScheduleFormTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleFormTableViewCell: UITableViewCell {

    // Mark: Variables
    var schedule: Schedule?

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Mark: Outlet Actions
    @IBAction func addAction(_ sender: Any) {
    }

    // Mark: Functions
    func setup(schedule: Schedule) {
        self.schedule = schedule
        setUpTable()
    }
    
}

extension ScheduleFormTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
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
            return 1
        }
    }

}
