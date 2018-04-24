//
//  RangeUsageTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RangeUsageTableViewCell: BaseFormCell {

    // MARK: Constants

    /*
     NOTE: update this if you update the cell height
     of RangeUseageYearTableViewCell in storyboard
     */
    let cellHeight = 49.5

    // MARK: Variables
    var usageYears = [RangeUsageYear]()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet actions
    @IBAction func addAction(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.rangeUsageYears.append(RangeUsageYear())
            }
        } catch _ {
            fatalError()
        }
        updateTableHeight()
    }

    // MARK: Functions
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        self.usageYears = [RangeUsageYear]()
        for usage in rup.rangeUsageYears {
            if usage.year >= (rup.agreementStartDate?.yearOfDate())! && usage.year <= (rup.agreementEndDate?.yearOfDate())! {
                usageYears.append(usage)
            }
        }
        heightConstraint.constant = CGFloat( Double(usageYears.count) * cellHeight + 5.0)
        setUpTable()
    }

    // MARK: Style
    // Calculate table height based on content and
    // reload parent's table view to bottom of
    // the indexpath of current cell
    func updateTableHeight() {  
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()

        heightConstraint.constant = CGFloat( Double(usageYears.count) * cellHeight + 5.0)

        /*
         tableView.contentSize.height did not provide correct height.
         not sure why but cells do have fixed height
         so we used the above alternative
        */

        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.rangeUsageIndexPath)
    }
}

// MARK: TableView
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
        cell.setup(usage: usageYears[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usageYears.count
    }

}
