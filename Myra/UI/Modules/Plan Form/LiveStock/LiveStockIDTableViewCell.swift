//
//  LiveStockIDTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class LiveStockIDTableViewCell: BaseFormCell {

    // Mark: Constants
    let cellHeight = 45
    
    // Mark: Variables

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // Mark: Outlet Actions
    @IBAction func addLiveStockAction(_ sender: Any) {
        guard let plan = self.plan else {return}
        plan.addLiveStock()
        updateTableHeight()
    }

    // Mark: Functions
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.plan = rup
        setUpTable()
    }

    func computeHeight() -> CGFloat {
        guard let plan = self.plan else {return 0}
        let padding: CGFloat = 5.0
        return CGFloat(CGFloat((plan.liveStockIDs.count)) * CGFloat(LiveStockTableViewCell.cellHeight) + padding)
    }

    func updateTableHeight() {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableViewHeight.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

}
extension LiveStockIDTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "LiveStockTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getLiveStockCell(indexPath: IndexPath) -> LiveStockTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LiveStockTableViewCell", for: indexPath) as! LiveStockTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getLiveStockCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plan = self.plan else {return 0}
        return plan.liveStockIDs.count
    }

}
