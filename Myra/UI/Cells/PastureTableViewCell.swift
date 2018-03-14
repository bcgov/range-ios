//
//  PastureTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

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
        self.pasture?.plantCommunities.append(PlantCommunity())
        updateTableHeight()
    }
    @IBAction func fieldChanged(_ sender: Any) {
        var currAUMs: Int = (self.pasture?.allowedAUMs)!
        var currDeudction: Double = (self.pasture?.privateLandDeduction)!
        var currGrace: Int = (self.pasture?.graceDays)!

        if (aumsField.text?.isInt)! {
             currAUMs = Int(aumsField.text!)!
        }

        if (deductionFIeld.text?.isDouble)! {
            currDeudction = Double(deductionFIeld.text!)!
        }

        if (graceDaysField.text?.isInt)! {
            currGrace = Int(graceDaysField.text!)!
        }

        self.pasture?.allowedAUMs = currAUMs
        self.pasture?.privateLandDeduction = currDeudction
        self.pasture?.graceDays = currGrace

        print("\(String(describing: self.pasture?.allowedAUMs)) AUMs")
        print("\(String(describing: self.pasture?.privateLandDeduction))%")
        print("\(String(describing: self.pasture?.graceDays)) Days")
    }

    // Mark: Functions
    func setup(mode: FormMode, pasture: Pasture, pastures: PasturesTableViewCell) {
        self.pastures = pastures
        self.mode = mode
        self.pasture = pasture
        self.pastureNameLabel.text = pasture.name
        setupTable()
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
