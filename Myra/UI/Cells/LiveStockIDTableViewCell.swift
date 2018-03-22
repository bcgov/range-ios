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

class LiveStockIDTableViewCell: UITableViewCell {

    // Mark: Constants
    let cellHeight = 45
    
    // Mark: Variables
    var rup: RUP?
    var mode: FormMode = .Create

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet Actions
    @IBAction func addLiveStockAction(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup?.liveStockIDs.append(LiveStockID())
            }
        } catch _ {
            fatalError()
        }
        updateTableHeight()
    }

    // Mark: Functions
    func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        setUpTable()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        tableViewHeight.constant = CGFloat((self.rup?.liveStockIDs.count)! * cellHeight + 5)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.liveStockIDIndexPath)
    }

//    func setInitialHeight(numberOfFields: Int) {
//        tableViewHeight.constant = CGFloat(numberOfFields * cellHeight + 5)
//    }

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
        return (self.rup?.liveStockIDs.count)!
    }

}
