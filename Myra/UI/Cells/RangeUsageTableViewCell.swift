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
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var header: UILabel!

    @IBOutlet weak var yearHeader: UILabel!
    @IBOutlet weak var authAUMHeader: UILabel!
    @IBOutlet weak var tempIncreaseHeader: UILabel!
    @IBOutlet weak var nonUseHeader: UILabel!
    @IBOutlet weak var totalAnnualHeader: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    // MARK: Cell functions

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
        if let plansStart = rup.planStartDate, let planEnd = rup.planEndDate {
            for usage in rup.rangeUsageYears where usage.year >= plansStart.yearOfDate()! && usage.year <= planEnd.yearOfDate()!  {
                usageYears.append(usage)
            }
            warningLabel.text = ""
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
        } else {
            // show message
            warningLabel.text = "Plan start and end dates have not been selected yet"
        }
        heightConstraint.constant = CGFloat( Double(usageYears.count) * cellHeight + 5.0)
        setUpTable()
        style()
    }

    // MARK: Style
    func style() {
        warningLabel.font = Fonts.getPrimary(size: 15)
        warningLabel.textColor = Colors.secondary
        styleSubHeader(label: header)
        styleDivider(divider: divider)
        styleFieldHeader(label: yearHeader)
        styleFieldHeader(label: authAUMHeader)
        styleFieldHeader(label: tempIncreaseHeader)
        styleFieldHeader(label: nonUseHeader)
        styleFieldHeader(label: totalAnnualHeader)
    }

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
        parent.reloadAt(indexPath: parent.rangeUsageIndexPath)
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
         if indexPath.row % 2 == 0 {
            cell.setup(usage: usageYears[indexPath.row], bg: Colors.evenCell)
         } else {
            cell.setup(usage: usageYears[indexPath.row], bg: Colors.oddCell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usageYears.count
    }

}
