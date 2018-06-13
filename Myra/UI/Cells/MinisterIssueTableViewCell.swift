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

    // MARK: Contants
    let actionCellHeight: CGFloat = 162

    // MARK: Variables
    var issue: MinisterIssue?
    var parentCell: MinisterIssuesTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var issueTypeHeader: UILabel!
    @IBOutlet weak var issueTypeValue: UILabel!
    @IBOutlet weak var pastureHeader: UILabel!
    @IBOutlet weak var pastureValue: UILabel!

    @IBOutlet weak var detailsHeader: UILabel!
    @IBOutlet weak var detailsValue: UITextView!

    @IBOutlet weak var objectiveHeader: UILabel!
    @IBOutlet weak var objectiveValue: UITextView!

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var actionsHeader: UILabel!

    @IBOutlet weak var addPastureButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var addPasturesButton: UIButton!
    @IBOutlet weak var pasturesButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!

    // MARK: Outlet actions
    @IBAction func optionsAction(_ sender: UIButton) {
        guard let i = self.issue, let parent = self.parentCell else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options) { (selected) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch selected.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "Would you like to remove this issue and all actions associated to it?", yesButtonTapped: {
                    RUPManager.shared.removeIssue(issue: i)
                    parent.updateTableHeight(scrollToBottom: false)
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
        
        lookup.setupLive(header: "select something",selected: selected, objects: pastureNames) { (selections) in
            if let selected = selections  {
                i.clearPastures()
                for selection in selected {
                    if let pasture = RUPManager.shared.getPastureNamed(name: selection.value, rup: self.rup) {
                        i.addPasture(pasture: pasture)
                    }
                }
                self.autofill()
            }
        }
//        lookup.setup(multiSelect: true, selected: selected, objects: pastureNames) { (selected, selections) in
//            if selected, let selected = selections {
//                i.clearPastures()
//                for selection in selected {
//                    if let pasture = RUPManager.shared.getPastureNamed(name: selection.value, rup: self.rup) {
//                        i.addPasture(pasture: pasture)
//                    }
//                }
//                self.autofill()
//                grandParent.hidepopup(vc: lookup)
//            } else {
//                grandParent.hidepopup(vc: lookup)
//            }
//        }
        grandParent.showPopUp(vc: lookup, on: sender)
    }

    @IBAction func addActionAction(_ sender: UIButton) {
        guard let i = self.issue else {return}
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: RUPManager.shared.getMinistersIssueActionsOptions()) { (selected, selection) in
            parent.dismissPopOver()
            if selected, let option = selection {
                if let type = RUPManager.shared.getIssueActionType(named: option.display) {
                    i.addAction(type: type)
                    self.updateTableHeight(scrollToBottom: false)
                }
            }
        }
        parent.showPopUp(vc: lookup, on: sender)
    }

    @IBAction func editTypeAction(_ sender: UIButton) {
        editType()
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
        setUpTable()
        style()
        autofill()
        tableHeight.constant = computeTableHeight()

        if mode == .Edit {
            let tap = UITapGestureRecognizer(target: self, action: #selector(changeIssueTypeAction))
            issueTypeValue.addGestureRecognizer(tap)
        }
    }

    @objc func changeIssueTypeAction(sender:UITapGestureRecognizer) {
        editType()
    }

    func editType(){
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: RUPManager.shared.getMinistersIssueTypesOptions()) { (selected, selection) in
            grandParent.dismissPopOver()
            if selected, let option = selection {
                if let i = self.issue {
                    i.set(issueType: option.display)
                    self.autofill()
                }
                self.updateTableHeight(scrollToBottom: false)
            }
        }
        grandParent.showPopUp(vc: lookup, on: issueTypeValue.layer, inView: containerView)
    }

    func autofill() {
        guard let i = self.issue else {return}
        // Grab pastures and style string
        var pastures = ""
        for pasture in i.pastures {
            pastures = "\(pastures)\(pasture.name), "
        }
        // Remove last space and comma
        pastures = pastures.trimmingCharacters(in: .whitespaces)
        if pastures.count > 1 {
            pastures = String(pastures.dropLast())
        }
        pastures = pastures.replacingLastOccurrenceOfString(",", with: ", and")
        if pastures.count > 1 {
            pastures = "\(pastures)."
        }

        // if there are only 2 pasture, remove comma
        if i.pastures.count == 2 {
            pastures = pastures.replacingLastOccurrenceOfString(",", with: "")
        }
        // Fill values
        pastureValue.text = pastures
        issueTypeValue.text = i.issueType
        detailsValue.text = i.details
        objectiveValue.text = i.objective

        if self.mode == .View {
            setDefaultValueIfEmpty(field: pastureValue)
            setDefaultValueIfEmpty(field: detailsValue)
            setDefaultValueIfEmpty(field: objectiveValue)
        }
    }

    func computeTableHeight() -> CGFloat {
        guard let i = self.issue else {return 0}
        return actionCellHeight * CGFloat(i.actions.count)
    }

    func updateTableHeight(scrollToBottom: Bool) {
        guard let parent = self.parentCell else {return}
        self.tableView.reloadData()
        tableView.layoutIfNeeded()
        tableHeight.constant = computeTableHeight()
        parent.updateTableHeight(scrollToBottom: scrollToBottom)
    }

    // MARK: Style
    func style() {
        styleContainer(view: containerView)
        styleSubHeader(label: issueTypeHeader)
        styleSubHeader(label: issueTypeValue)
        styleStaticField(field: pastureValue, header: pastureHeader)
        styleSubHeader(label: actionsHeader)
        switch self.mode {
        case .View:
            addPastureButtonWidth.constant = 0
            optionsButton.alpha = 0
            addButton.alpha = 0
            addPasturesButton.alpha = 0
            editButton.alpha = 0
            pasturesButton.isUserInteractionEnabled = false
            styleTextviewInputFieldReadOnly(field: detailsValue, header: detailsHeader)
            styleTextviewInputFieldReadOnly(field: objectiveValue, header: objectiveHeader)
        case .Edit:
            styleFillButton(button: addPasturesButton)
            styleFillButton(button: addButton)
            makeCircle(button: addPasturesButton)
            addShadow(layer: addPasturesButton.layer)
            styleTextviewInputField(field: detailsValue, header: detailsHeader)
            styleTextviewInputField(field: objectiveValue, header: objectiveHeader)
        }
    }

    // MARK: Utilities
    func deleteAction(action: MinisterIssueAction) {
        guard let i = self.issue else {return}
        RealmRequests.deleteObject(action)
        do {
            let realm = try Realm()
            let anIssue = realm.objects(MinisterIssue.self).filter("localId = %@", i.localId).first!
            self.issue = anIssue
        } catch _ {
            fatalError()
        }
        updateTableHeight(scrollToBottom: false)
    }
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
        cell.setup(action: i.actions[indexPath.row], parent: self, mode: mode, rup: rup)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let i = issue {
            return i.actions.count
        } else {
            return 0
        }
    }
}
