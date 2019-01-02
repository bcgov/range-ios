//
//  MinisterIssuesTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MinisterIssuesTableViewCell: BaseFormCell {

    // MARK: Variables
    var objects: [MinisterIssue] = [MinisterIssue]()

    // MARK: Outlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitle: UILabel!

    // MARK: Outlet Actions


    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Minister’s Issues and Actions", desc: InfoTips.ministersIssuesandActions)
    }

    // misleading name. this adds an issue. its the action of adding an issue.
    @IBAction func addAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: Options.shared.getMinistersIssueTypesOptions(), onVC: parent, onButton: sender) { (selected, selection) in
            parent.dismissPopOver()
            if selected, let option = selection {
                let newIssue = MinisterIssue()
                guard let type = Reference.shared.getIssueType(named: option.display), let refetchedPlan = self.refetchPlan() else {return}
                newIssue.issueType = option.display
                newIssue.issueTypeID = type.id
                refetchedPlan.addMinisterIssue(object: newIssue)
                NewElementAddedBanner.shared.show()
                self.plan = refetchedPlan
                self.updateTableHeight(scrollToBottom: true, then: {})
            }
        }
    }


    // MARK: Setup
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.plan = rup
        for element in rup.ministerIssues {
            objects.append(element)
        }
        tableHeight.constant = computeHeight()
        setUpTable()
        style()
    }

    // MARK: Functions
    func updateTableHeight(scrollToBottom: Bool, then: @escaping() -> Void) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableHeight.constant = computeHeight()
        if scrollToBottom {
            parent.realod(bottomOf: parent.minsterActionsIndexPath) {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                return then()
            }
        } else {
            parent.reload {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                return then()
            }
        }
    }

    func computeHeight() -> CGFloat {
        guard let plan = self.plan else {return 0}
        /*
         Height of Minister's Issues cell
         this module has Minster's issue cells, which have action cells
         */
        let padding: CGFloat = 7
        var h: CGFloat = 0.0
        for issue in (plan.ministerIssues) {
            h = h + computeMinisterIssueHeight(issue: issue) + padding
        }
        return h
    }

    func computeMinisterIssueHeight(issue: MinisterIssue) -> CGFloat {
        /*
         This module has Action cells
         */
        
        return (MinisterIssueTableViewCell.cellHeight + (MinistersIssueActionTableViewCell.cellHeight * CGFloat(issue.actions.count)))
    }

    // MARK: Style
    func style() {
        styleHeader(label: titleLabel, divider: divider)
        titleLabel.increaseFontSize(by: -4)
        styleSubHeader(label: subtitle)
        switch self.mode {
        case .View:
            self.addButton.alpha = 0
        case .Edit:
            styleHollowButton(button: addButton)
        }
    }
    
}
// MARK: TableView
extension MinisterIssuesTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "MinisterIssueTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getIssueCell(indexPath: IndexPath) -> MinisterIssueTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MinisterIssueTableViewCell", for: indexPath) as! MinisterIssueTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getIssueCell(indexPath: indexPath)
        if let plan = self.plan {
            cell.setup(issue: plan.ministerIssues[indexPath.row],mode: mode, rup: plan, parent: self)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plan = self.plan else {return 0}
        return plan.ministerIssues.count
    }

}
