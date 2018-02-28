//
//  RangeUsageTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class RangeUsageTableViewCell: UITableViewCell {

    // Mark: Constants

    /* NOTE: update this if you update the cell height
     of RangeUseageYearTableViewCell
     */
    let cellHeight = 76

    // Mark: Variables
    var rangeUsageYears: [RangeUsageYear] = [RangeUsageYear]()

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
//        tableView.reloadData()
        self.tableView.isScrollEnabled = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet actions
    @IBAction func addAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.rangeUseYears.append(DummySupplier.shared.getRangeUseYear())
        updateTableHeight()
        parent.realodAndGoTO(indexPath: parent.rangeUsageIndexPath)
    }

    // Mark: Functions
    func setup(rangeUsageYears: [RangeUsageYear]) {
        self.rangeUsageYears = rangeUsageYears
        setUpTable()
    }

    func updateTableHeight() {
        self.tableView.reloadData()
        heightConstraint.constant = CGFloat((rangeUsageYears.count) * cellHeight + 5)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }
}

extension RangeUsageTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "RangeUseageYearTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getYearCell(indexPath: IndexPath) -> RangeUseageYearTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "RangeUseageYearTableViewCell", for: indexPath) as! RangeUseageYearTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getYearCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rangeUsageYears.count
    }

}
