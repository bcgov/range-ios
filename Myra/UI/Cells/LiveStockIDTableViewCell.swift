//
//  LiveStockIDTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class LiveStockIDTableViewCell: UITableViewCell {
    
    // Mark: Variables
    var liveStockIDs: [LiveStockID] = [LiveStockID]()

    // Mark: Constants
    let cellHeight = 40

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        tableView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet Actions
    @IBAction func addLiveStockAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.liveStockIDs.append(DummySupplier.shared.getLiveStockID())
        updateTableHeight()
        self.tableView.reloadData()
        parent.realodAndGoTO(indexPath: parent.liveStockIDIndexPath)
    }

    // Mark: Functions
    func setInitialHeight(numberOfFields: Int) {
        tableViewHeight.constant = CGFloat(numberOfFields * cellHeight + 5)
    }

    func updateTableHeight() {
        tableViewHeight.constant = CGFloat((liveStockIDs.count) * cellHeight + 5)
        print(tableViewHeight.constant)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }

    func setup(liveStockIDs: [LiveStockID]) {
        self.liveStockIDs = liveStockIDs
        setUpTable()
    }

}
extension LiveStockIDTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
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
        return liveStockIDs.count
    }

}
