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

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // Mark: Outlet actions
    @IBAction func addPastureAction(_ sender: Any) {
        updateTableHeight()
    }

    // Mark: Functions
    func setup(pastures: [Pasture]) {
        self.pastures = pastures
    }

    func updateTableHeight() {
        tableView.layoutIfNeeded()

        tableHeight.constant =  tableView.contentSize.height
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }
    
}

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
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastures.count
    }

}

