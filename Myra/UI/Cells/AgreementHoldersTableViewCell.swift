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
    let cellHeight = 45
    
    // MARK: Variables

    // MARK: Outlets
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var agreementTypeHeader: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: functions
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        style()
        setUpTable()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        if let p = self.parentViewController as? CreateNewRUPViewController {
            let clients = rup.clients
            heightConstraint.constant = CGFloat((clients.count) * cellHeight + 5)
            p.realodAndGoTO(indexPath: p.basicInformationIndexPath)
        }
    }

    // MARK: Styles
    func style() {
        styleDivider(divider: divider)
        styleSubHeader(label: header)
        styleFieldHeader(label: agreementTypeHeader)
        styleFieldHeader(label: agreementHolderHeader)
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
         cell.setup(client: rup.clients[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return rup.clients.count
    }

}

