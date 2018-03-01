//
//  PasturesTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PasturesTableViewCell: UITableViewCell {

    // Mark: Variables
    var pastures: [Pasture] = [Pasture]()
    var mode: FormMode = .Create

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
//        setUpTable()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // Mark: Outlet actions
    @IBAction func addPastureAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.pastures.append(Pasture(name: "name"))
        self.pastures = parent.pastures
        updateTableHeight()
        parent.realodAndGoTO(indexPath: parent.pasturesIndexPath)

    }

    // Mark: Functions
    func setup(mode: FormMode, pastures: [Pasture]) {
        self.mode = mode
        self.pastures = pastures
        setUpTable()
        setupNotifications()
    }

    func updateTableHeight() {
        self.tableView.reloadData()
        tableView.layoutIfNeeded()
        tableHeight.constant =  tableView.contentSize.height
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }
    
}

// TableView
extension PasturesTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PastureTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getYearCell(indexPath: IndexPath) -> PastureTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PastureTableViewCell", for: indexPath) as! PastureTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getYearCell(indexPath: indexPath)
        if pastures.count <= indexPath.row {return cell}
        cell.setup(pasture: pastures[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastures.count
    }

}

// Notifications
extension PasturesTableViewCell {
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .updatePasturesCell, object: nil, queue: nil, using: catchAction)
//         NotificationCenter.default.addObserver(forName: .updateTableHeights, object: nil, queue: nil, using: catchUpdateAction)
    }

    func catchAction(notification:Notification) {
        self.updateTableHeight()
    }

    func catchUpdateAction(notification:Notification) {
        self.updateTableHeight()
    }
}

