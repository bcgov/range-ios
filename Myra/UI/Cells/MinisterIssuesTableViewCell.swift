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

    // misleading name. this adds an issue. its the action of adding an issue.
    @IBAction func addAction(_ sender: UIButton) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let option1 = SelectionPopUpObject(display: "first thing", value: "first thing")
        let option2 = SelectionPopUpObject(display: "second thing", value: "second thing")
        lookup.setup(objects: [option1, option2]) { (selected, selection) in
            if selected, let option = selection {
                let newIssue = MinisterIssue()
                newIssue.issueType = option.display
                do {
                    let realm = try Realm()
                    let aRup = realm.objects(RUP.self).filter("localId = %@", self.rup.localId).first!
                    try realm.write {
                        aRup.ministerIssues.append(newIssue)
                        realm.add(newIssue)
                    }
                    self.rup = aRup
                } catch _ {
                    fatalError()
                }
                parent.dismissPopOver()
                self.updateTableHeight()
            } else {
                parent.dismissPopOver()
            }
        }
        parent.showPopUp(vc: lookup, on: sender)
    }

    // MARK: Setup
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        for element in rup.ministerIssues {
            objects.append(element)
        }
        tableHeight.constant = computeHeight()
        setUpTable()
        style()
    }

    // MARK: Functions
    func updateTableHeight() {
        self.tableView.reloadData()
        tableView.layoutIfNeeded()
        tableHeight.constant = computeHeight()
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoToBottomOf(indexPath: parent.minsterActionsIndexPath)
    }

    func computeHeight() -> CGFloat {
        /*
         Height of Minister's Issues cell
         this module has Minster's issue cells, which have action cells
         */
        let padding: CGFloat = 7
        var h: CGFloat = 0.0
        for issue in (rup.ministerIssues) {
            h = h + computeMinisterIssueHeight(issue: issue) + padding
        }
        return h
    }

    func computeMinisterIssueHeight(issue: MinisterIssue) -> CGFloat {
        /*
         This module has Action cells
        */
        let staticHeight: CGFloat = 670
        let actionHeight: CGFloat = 158
        return (staticHeight + (actionHeight * CGFloat(issue.actions.count)))
    }

    // MARK: Style
    func style() {
        styleHeader(label: titleLabel, divider: divider)
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
        cell.setup(issue: rup.ministerIssues[indexPath.row],mode: mode, rup: rup, parent: self)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rup.ministerIssues.count
    }

}
