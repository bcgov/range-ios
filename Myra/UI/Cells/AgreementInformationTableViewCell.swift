//
//  AgreementInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

// Works exactly like Range useage years cell, but with different object
// refer to RangeUsageTableViewCell for better comments
class AgreementInformationTableViewCell: UITableViewCell {

    // Mark: Constants
    let cellHeight = 45

    // Mark: Variables
    var agreementHolders: [AgreementHolder] = [AgreementHolder]()
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
    @IBAction func addAgreementHolderAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.rup?.agreementHolders.append(AgreementHolder())
        self.agreementHolders = (parent.rup?.agreementHolders)!
        updateTableHeight()
    }

    // Mark: Functions
    func setup(mode: FormMode, agreementHolders: [AgreementHolder]) {
        self.mode = mode
        self.agreementHolders = agreementHolders
        setUpTable()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        tableViewHeight.constant = CGFloat((agreementHolders.count) * cellHeight + 5)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.agreementInformationIndexPath)
    }
}

extension AgreementInformationTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AgreementHolderTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getHolderCell(indexPath: IndexPath) -> AgreementHolderTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AgreementHolderTableViewCell", for: indexPath) as! AgreementHolderTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getHolderCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agreementHolders.count
    }

}

