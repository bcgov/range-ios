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
import Extended

class RangeUsageTableViewCell: BaseFormCell {

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
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Usage", desc: InfoTips.usage)

    }

    @IBAction func addAction(_ sender: Any) {
        guard let plan = self.plan else {return}
        do {
            let realm = try Realm()
            try realm.write {
                plan.rangeUsageYears.append(RangeUsageYear())
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        updateTableHeight()
    }

    // MARK: Setup
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.plan = rup
        setUpTable()
        self.usageYears = [RangeUsageYear]()
        if let plansStart = rup.planStartDate, let planEnd = rup.planEndDate {
            for usage in rup.rangeUsageYears where usage.year >= plansStart.year() && usage.year <= planEnd.year()  {
                usageYears.append(usage)
            }
            warningLabel.text = ""
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
        } else {
            // show message
            warningLabel.text = "Plan start and end dates have not been selected yet"
        }
        heightConstraint.constant = computeCellHeight()
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

    // MARK: Dynamic cell height
    func computeCellHeight() -> CGFloat {
        let padding: CGFloat = 5.0
        return CGFloat( CGFloat(usageYears.count) * CGFloat(RangeUseageYearTableViewCell.cellHeight) + padding)
    }

    func updateTableHeight() {
        let parent = self.parentViewController as! CreateNewRUPViewController
        heightConstraint.constant = computeCellHeight()
        parent.reload{
            self.tableView.reloadData()
        }
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
