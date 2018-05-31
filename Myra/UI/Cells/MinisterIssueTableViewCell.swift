//
//  MinisterIssueTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MinisterIssueTableViewCell: BaseFormCell {

    // MARK: Variables
    var issue: MinisterIssue?
    var parentCell: MinisterIssuesTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var issueTypeHeader: UILabel!
    @IBOutlet weak var issueTypeValue: UILabel!
    @IBOutlet weak var pastureHeader: UILabel!
    @IBOutlet weak var pastureValue: UILabel!

    @IBOutlet weak var detailsHeader: UILabel!
    @IBOutlet weak var detailsValue: UITextView!

    @IBOutlet weak var objectiveHeader: UILabel!
    @IBOutlet weak var objectiveValue: UITextView!

    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionValue: UITextView!

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var actionsHeader: UILabel!

    // MARK: Outlet actions

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let i = self.issue, let parent = self.parentCell else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete"), Option(type: .Delete, display: "Copy")]
        optionsVC.setup(options: options) { (selected) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch selected.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "Would you like to remove this issue and all actions associated to it?", yesButtonTapped: {
                    RUPManager.shared.removeIssue(issue: i)
                    parent.updateTableHeight()
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }

        grandParent.showPopOver(on: sender, vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)
    }

    @IBAction func pasturesAction(_ sender: UIButton) {
        guard let i = issue else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let pastureNames = RUPManager.shared.getPasturesLookup(rup: rup)
        var selected = [SelectionPopUpObject]()
        for pasture in i.pastures {
            selected.append(SelectionPopUpObject(display: pasture.name, value: pasture.name))
        }
        lookup.setup(multiSelect: true, selected: selected, objects: pastureNames) { (selected, selections) in
            if selected, let selected = selections {
                i.clearPastures()
                for selection in selected {
                    if let pasture = RUPManager.shared.getPastureNamed(name: selection.value, rup: self.rup) {
                        i.addPasture(pasture: pasture)
                    }
                }
                self.autofill()
                grandParent.hidepopup(vc: lookup)
            } else {
                grandParent.hidepopup(vc: lookup)
            }
        }
        grandParent.showPopUp(vc: lookup, on: sender)
    }
    
    // MARK: Functions
    // MARK: Setup
    func setup(issue: MinisterIssue, mode: FormMode, rup: RUP, parent: MinisterIssuesTableViewCell) {
        self.rup = rup
        self.mode = mode
        self.issue = issue
        self.parentCell = parent
        detailsValue.delegate = self
        objectiveValue.delegate = self
        descriptionValue.delegate = self
        style()
        autofill()
    }

    func autofill() {
        guard let i = self.issue else {return}
        var pastures = ""
        for pasture in i.pastures {
            pastures = "\(pastures)\(pasture.name), "
        }
        pastureValue.text = pastures
        issueTypeValue.text = i.issueType
        detailsValue.text = i.details
        objectiveValue.text = i.objective
        descriptionValue.text = i.desc
    }

    // MARK: Style
    func style() {
        styleContainer(view: containerView)
        styleSubHeader(label: issueTypeHeader)
        styleSubHeader(label: issueTypeValue)
        styleFillButton(button: addButton)
        styleStaticField(field: pastureValue, header: pastureHeader)
        styleTextviewInputField(field: detailsValue, header: detailsHeader)
        styleTextviewInputField(field: objectiveValue, header: objectiveHeader)
        styleTextviewInputField(field: descriptionValue, header: descriptionHeader)
        styleHeader(label: actionsHeader)
    }

    // MARK: Utilities
    func duplicate() {

    }
}

// MARK: TextView delegates
extension MinisterIssueTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let i = issue else {return}
        switch textView {
        case detailsValue:
            i.set(details: textView.text)
        case objectiveValue:
            i.set(objective: textView.text)
        case descriptionValue:
            i.set(desc: textView.text)
        default:
            return
        }
    }
}

// MARK: TableView
extension MinisterIssueTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "MinistersIssueActionTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getIssueCell(indexPath: IndexPath) -> MinistersIssueActionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MinistersIssueActionTableViewCell", for: indexPath) as! MinistersIssueActionTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let i = issue else { return UITableViewCell()}
        let cell = getIssueCell(indexPath: indexPath)
        cell.setup(action: i.actions[indexPath.row],mode: mode, rup: rup)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rup.ministerIssues.count
    }
}
