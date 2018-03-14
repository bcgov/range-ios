//
//  ScheduleTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    let cellHeight = 56.5
    var rup: RUP?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addScheduleAction(_ sender: UIButton) {
        self.rup?.schedules.append(Schedule())
        print(rup?.schedules.count)
        updateTableHeight()
    }

    func setup(rup: RUP) {
        self.rup = rup
        setUpTable()
        style()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        print(rup?.schedules.count)
        let count = rup?.schedules.count ?? 0
        tableHeight.constant = CGFloat( Double(count) * cellHeight + 5.0)
        print(tableHeight.constant)
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
        cell.setup(schedule: (rup?.schedules[indexPath.row])!)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("seleted")
//        let parent = self.parentViewController as! CreateNewRUPViewController
//        parent.showSchedule(object: (rup?.schedules[indexPath.row])!)
    }

}
