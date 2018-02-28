//
//  AgreementInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementInformationTableViewCell: UITableViewCell {

    // Mark: Variables
    var agreementHolders: [AgreementHolder] = [AgreementHolder]()

    // Mark: Constants
    let cellHeight = 40

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
//        tableView.reloadData()
        self.tableView.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet Actions
    @IBAction func addAgreementHolderAction(_ sender: Any) {
//        updateTableHeight()
//        self.tableView.reloadData()
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.agreementHolders.append(DummySupplier.shared.getAgreementHolder())
        updateTableHeight()
        self.tableView.reloadData()
        parent.realodAndGoTO(indexPath: parent.agreementInformationIndexPath)
    }

    // Mark: Functions
    func updateTableHeight() {
        tableViewHeight.constant = CGFloat((agreementHolders.count) * cellHeight + 5)
        print(tableViewHeight.constant)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }

    func setup(agreementHolders: [AgreementHolder]) {
        self.agreementHolders = agreementHolders
        setUpTable()
    }
}

extension AgreementInformationTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
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

