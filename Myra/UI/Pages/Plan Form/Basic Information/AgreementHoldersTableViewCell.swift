//
//  AgreementHoldersTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-24.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AgreementHoldersTableViewCell: BaseFormCell {

    // MARK: Constants
    static let cellHeight = 45

    // MARK: Variables

    // MARK: Outlets
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var agreementTypeHeader: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    // MARK: Setup
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.plan = rup
        heightConstraint.constant = computeCellHeight()
        style()
        setUpTable()
    }

    // MARK: Styles
    func style() {
        styleDivider(divider: divider)
        styleSubHeader(label: header)
        styleFieldHeader(label: agreementTypeHeader)
        styleFieldHeader(label: agreementHolderHeader)
    }

    // MARK: Dynamic cell height
    func computeCellHeight() -> CGFloat {
        guard let plan = self.plan else {return 0}
        let padding = 5
        return CGFloat((plan.clients.count) * AgreementHoldersTableViewCell.cellHeight + padding)
    }

    func updateTableHeight() {
        let parent = self.parentViewController as! CreateNewRUPViewController
        heightConstraint.constant = computeCellHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
}

extension AgreementHoldersTableViewCell: UITableViewDelegate, UITableViewDataSource {
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
        guard let plan = self.plan else {return cell}
        cell.setup(client: plan.clients[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plan = self.plan else {return 0}
        return plan.clients.count
    }
}

