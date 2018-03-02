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

    /*
     NOTE: update this if you update the cell height
     of RangeUseageYearTableViewCell in storyboard
     */
    let cellHeight = 49.5

    // Mark: Variables
    var rangeUsageYears: [RangeUsageYear] = [RangeUsageYear]()
    var mode: FormMode = .Create

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet actions

    // adds new range use year object to parent's rup object
    // then updates this class' range use years to compute height
    @IBAction func addAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.rup?.rangeUsageYears.append(RangeUsageYear())
        self.rangeUsageYears = (parent.rup?.rangeUsageYears)!
        updateTableHeight()
    }

    // Mark: Functions
    func setup(mode: FormMode, rangeUsageYears: [RangeUsageYear]) {
        self.mode = mode
        self.rangeUsageYears = rangeUsageYears
        setUpTable()
    }

    // Calculate table height based on content and
    // reload parent's table view to bottom of
    // the indexpath of current cell
    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()

        heightConstraint.constant = CGFloat( Double(rangeUsageYears.count) * cellHeight + 5.0)

        /*
         tableView.contentSize.height did not provide correct height.
         not sure why but cells do have fixed height
         so we used the above alternative
        */

        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.rangeUsageIndexPath)
    }
}

// TableView
extension RangeUsageTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        self.tableView.isScrollEnabled = false
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
