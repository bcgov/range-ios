//
//  PasturesTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

/*
 Pastures uses a different logic than range years cell for height:
 the height of pasture cells within the table view depends on the height
 of the content of a pasture's conent which will be unpredictable.
 */
class PasturesTableViewCell: BaseFormCell {
    
    // MARK: Outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    // MARK: Outlet actions
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Pastures", desc: InfoTips.pastures)
    }
    
    @IBAction func addPastureAction(_ sender: Any) {
        guard let plan = self.plan else {return}
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Pasture Name", taken: Options.shared.getPastureNames(rup: plan)) { (name) in
            if name != "" {
                plan.addPasture(withName: name)
                NewElementAddedBanner.shared.show()
                self.updateTableHeight(newAdded: true)
            }
        }
    }
    
    // MARK: Setup
    override func setup(mode: FormMode, rup: Plan) {
        self.plan = rup
        self.mode = mode
        switch mode {
        case .View:
            addButton.isEnabled = false
            addButton.alpha = 0
        case .Edit:
            addButton.isEnabled = true
            addButton.alpha = 1
        }
        tableHeight.constant = computeHeight()
        setUpTable()
        style()
    }
    
    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        sectionTitle.increaseFontSize(by: -4)
        styleHollowButton(button: addButton)
    }
    
    // MARK: Dynamic Cell Height
    func updateTableHeight(newAdded: Bool? = false) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableHeight.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    
    func computeHeight() -> CGFloat {
        guard let plan = self.plan else {return 0}
        /*
         Height of Pastures cell =
         */
        let padding: CGFloat = 5
        var h: CGFloat = 0.0
        for pasture in (plan.pastures) {
            h = h + computePastureHeight(pasture: pasture) + padding
        }
        if h == 0.0 {
            return 230
        } else {
            return h
        }
    }
    
    func computePastureHeight(pasture: Pasture) -> CGFloat {
        let staticHeight: CGFloat = 442
        let plantCommunityHeight: CGFloat = CGFloat(PlantCommunityTableViewCell.cellHeight)
        return (staticHeight + plantCommunityHeight * CGFloat(pasture.plantCommunities.count))
    }
}

// TableView
extension PasturesTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func setUpTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PastureTableViewCell")
        registerCell(name: "EmptyStateTableViewCell")
    }
    
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getPastureCell(indexPath: IndexPath) -> PastureTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PastureTableViewCell", for: indexPath) as! PastureTableViewCell
    }
    
    func getEmptyPastureCell(indexPath: IndexPath) -> EmptyStateTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "EmptyStateTableViewCell", for: indexPath) as! EmptyStateTableViewCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let plan = self.plan else {return UITableViewCell()}
        let count = plan.pastures.count
        if count < 1 {
            let emptyCell = getEmptyPastureCell(indexPath: indexPath)
            emptyCell.setup(message: "At least one pasture is required", fixedHeight: 200)
            return emptyCell
        }
        let cell = getPastureCell(indexPath: indexPath)
        if (plan.pastures.count) <= indexPath.row {return UITableViewCell()}
        cell.setup(mode: mode, pasture: (plan.pastures[indexPath.row]), plan: plan, pastures: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plan = self.plan else {return 0}
        let count = plan.pastures.count
        if count < 1 {
            return 1
        } else {
            return count
        }
    }
}
