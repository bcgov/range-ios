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
    func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        setUpTable()
        autofill()
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        tableHeight.constant = CGFloat((rup?.agreementHolders.count)! * cellHeight + 5)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.agreementInformationIndexPath)
    }

    func autofill() {
        if rup == nil { return }
        if mode == .View || mode == .Edit {
            self.planNumber.text = rup?.basicInformation?.rangeNumber
            self.agreementStart.text = rup?.basicInformation?.agreementStart.string()
            self.agreementEnd.text = rup?.basicInformation?.agreementEnd.string()
        } else {
            if let rangeNumber = rup?.agreementId {
                self.planNumber.text =  rangeNumber
            }
            if let start = rup?.agreementStartDate {
                self.agreementStart.text = DateManager.toString(date: start)
            }
            if let end = rup?.agreementEndDate {
                self.agreementEnd.text = DateManager.toString(date: end)
            }
        }
    }

    func setFieldMode() {
        switch mode {
        case .Create:
            addButton.isUserInteractionEnabled = true
            planNumber.isUserInteractionEnabled = true
            agreementStart.isUserInteractionEnabled = true
            agreementEnd.isUserInteractionEnabled = true
            addButton.isUserInteractionEnabled = true
        case .Edit:
            addButton.isUserInteractionEnabled = true
            planNumber.isUserInteractionEnabled = true
            agreementStart.isUserInteractionEnabled = true
            agreementEnd.isUserInteractionEnabled = true
            addButton.isUserInteractionEnabled = true
        case .View:
            addButton.isUserInteractionEnabled = false
            planNumber.isUserInteractionEnabled = false
            agreementStart.isUserInteractionEnabled = false
            agreementEnd.isUserInteractionEnabled = false
            addButton.isUserInteractionEnabled = false
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
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rup!.agreementHolders.count
    }

}

