//
//  PastureTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PastureTableViewCell: UITableViewCell {

    // Mark: Constants
    let plantCommunityCellHeight = 100

    // Mark: Variables
    var pastures: PasturesTableViewCell?
    var pasture: Pasture?
    var mode: FormMode = .Create
    var loaded: Bool = false

    // Mark: Outlets
    @IBOutlet weak var pastureNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
 
    @IBOutlet weak var pastureNotesTextField: UITextView!
    @IBOutlet weak var aumsField: UITextField!
    @IBOutlet weak var deductionFIeld: UITextField!
    @IBOutlet weak var graceDaysField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        addBoarder()
        loaded = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Mark: Outlet Actions
    @IBAction func addPlantCommunityAction(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.pasture?.plantCommunities.append(PlantCommunity())
            }
        } catch _ {
            fatalError()
        }
        updateTableHeight()
    }
    @IBAction func aumChanged(_ sender: UITextField) {
        do {
            let realm = try Realm()
            try realm.write {
                if (aumsField.text?.isInt)! {
                    self.pasture?.allowedAUMs = Int(aumsField.text!)!
                    aumsField.textColor = UIColor.black
                } else {
                    aumsField.textColor = UIColor.red
                    self.pasture?.allowedAUMs = 0
                }
            }
        } catch _ {
            fatalError()
        }

        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (pastures?.rup)!)

    }

    @IBAction func landDeductionChanged(_ sender: UITextField) {
        do {
            let realm = try Realm()
            try realm.write {
                if (deductionFIeld.text?.isDouble)! {
                    self.pasture?.privateLandDeduction = Double(deductionFIeld.text!)!
                    deductionFIeld.textColor = UIColor.black
                } else {
                    deductionFIeld.textColor = UIColor.red
                    self.pasture?.privateLandDeduction = 0.0
                }
            }
        } catch _ {
            fatalError()
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (pastures?.rup)!)
    }

    @IBAction func graceDaysChanged(_ sender: UITextField) {
        do {
            let realm = try Realm()
            try realm.write {
                if (graceDaysField.text?.isInt)! {
                    self.pasture?.graceDays = Int(graceDaysField.text!)!
                    graceDaysField.textColor = UIColor.black
                } else {
                    graceDaysField.textColor = UIColor.red
                    self.pasture?.graceDays = 0
                }
            }
        } catch _ {
            fatalError()
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (pastures?.rup)!)

    }

    @IBAction func fieldChanged(_ sender: Any) {}

    // Mark: Functions
    func setup(mode: FormMode, pasture: Pasture, pastures: PasturesTableViewCell) {
        self.pastures = pastures
        self.mode = mode
        self.pasture = pasture
        self.pastureNameLabel.text = pasture.name
        autofill()
        setupTable()
    }

    func autofill() {
        self.aumsField.text = "\(pasture?.allowedAUMs ?? 0)"
        self.deductionFIeld.text = "\(pasture?.privateLandDeduction ?? 0)"
        self.graceDaysField.text = "\(pasture?.graceDays ?? 0)"
    }

    func getCellHeight() -> CGSize {
        return self.frame.size
    }

    func updateTableHeight() {
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        tableHeight.constant = CGFloat((self.pasture?.plantCommunities.count)! * plantCommunityCellHeight + 5)
        if let parent = pastures {
            parent.updateTableHeight()
        }
    }

    func addBoarder() {
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 5
        containerView.layer.borderColor = UIColor.black.cgColor
    }
}

// TableView
extension PastureTableViewCell : UITableViewDelegate, UITableViewDataSource {

    func setupTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PlantCommunityTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getPlantCommunityCell(indexPath: IndexPath) -> PlantCommunityTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityTableViewCell", for: indexPath) as! PlantCommunityTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getPlantCommunityCell(indexPath: indexPath)
        cell.setup(mode: .Create, plantCommunity: (self.pasture?.plantCommunities[indexPath.row])!)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.pasture?.plantCommunities.count)!
    }

}

// Notifications
extension PastureTableViewCell {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updatePasturesCell, object: nil)
        NotificationCenter.default.addObserver(forName: .updatePastureCells, object: nil, queue: nil, using: catchAction)
    }

    @objc func doThisWhenNotify() { return }

    func notifyPasturesCell() {
        NotificationCenter.default.post(name: .updatePasturesCell, object: self, userInfo: ["reload": true])
    }

    func catchAction(notification:Notification) {
        self.updateTableHeight()
    }
}
