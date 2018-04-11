//
//  BasicInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

// Works exactly like Range useage years cell
// refer to RangeUsageTableViewCell for better comments
class BasicInfoTableViewCell: UITableViewCell {

    // Mark: Constants
    let cellHeight = 45

    // Mark: Variables
    var mode: FormMode = .Create
    var rup: RUP?

    var parentReference: CreateNewRUPViewController?

    // Mark: Outlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var planNumber: UITextField!
    @IBOutlet weak var agreementStart: UITextField!
    @IBOutlet weak var agreementEnd: UITextField!

    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addButton.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addAction(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                rup?.agreementHolders.append(AgreementHolder())
            }
        } catch _ {
            fatalError()
        }
        updateTableHeight()
    }


    // Mark: Functions
    func setup(mode: FormMode, rup: RUP, parentReference: CreateNewRUPViewController) {
        self.parentReference = parentReference
        self.mode = mode
        self.rup = rup
        setUpTable()
        autofill()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        if let r = rup, let p = parentReference {
            let clients = r.clients
            tableHeight.constant = CGFloat((clients.count) * cellHeight + 5)
            p.realodAndGoTO(indexPath: p.basicInformationIndexPath)
//            p.realodAndGoTO(indexPath: parent.agreementInformationIndexPath)
        }
    }

    func autofill() {
        if rup == nil { return }
        setFieldMode()

        if let rangeNumber = rup?.agreementId {
            self.planNumber.text =  rangeNumber
        }
        if let start = rup?.agreementStartDate {
            self.agreementStart.text = DateManager.toString(date: start)
        }
        if let end = rup?.agreementEndDate {
            self.agreementEnd.text = DateManager.toString(date: end)
        }
        updateTableHeight()


//        if mode == .View || mode == .Edit {
//            self.planNumber.text = rup?.basicInformation?.rangeNumber
//            self.agreementStart.text = rup?.basicInformation?.agreementStart.string()
//            self.agreementEnd.text = rup?.basicInformation?.agreementEnd.string()
//        } else {
//            if let rangeNumber = rup?.agreementId {
//                self.planNumber.text =  rangeNumber
//            }
//            if let start = rup?.agreementStartDate {
//                self.agreementStart.text = DateManager.toString(date: start)
//            }
//            if let end = rup?.agreementEndDate {
//                self.agreementEnd.text = DateManager.toString(date: end)
//            }
//        }
    }

    func setFieldMode() {
        switch mode {
        case .Create:
            addButton.isUserInteractionEnabled = true
            planNumber.isUserInteractionEnabled = false
            agreementStart.isUserInteractionEnabled = false
            agreementEnd.isUserInteractionEnabled = false
        case .Edit:
            addButton.isUserInteractionEnabled = true
            planNumber.isUserInteractionEnabled = false
            agreementStart.isUserInteractionEnabled = false
            agreementEnd.isUserInteractionEnabled = false
        case .View:
            addButton.isUserInteractionEnabled = false
            planNumber.isUserInteractionEnabled = false
            agreementStart.isUserInteractionEnabled = false
            agreementEnd.isUserInteractionEnabled = false
        }
    }
}

extension BasicInfoTableViewCell: UITableViewDelegate, UITableViewDataSource {
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
        if let r = rup {
            cell.setup(client: r.clients[indexPath.row], parentCell: self)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let r = rup {
            return r.clients.count
        } else {
            return 0
        }
//        return rup!.agreementHolders.count
    }

}

