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
    static let cellHeight: CGFloat = 624

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

    @IBOutlet weak var identifiedByMinisterLabel: UILabel!
    @IBOutlet weak var identifiedByMinisterSwitch: UISwitch!

    @IBOutlet weak var noteLabel: UILabel!
    

    // MARK: Outlet actions
    @IBAction func idengifiedByMinisterSwitchAction(_ sender: UISwitch) {
        guard let i = self.issue else {return}
        do {
            let realm = try Realm()
            try realm.write {
                i.identified = !i.identified
            }
        } catch _ {
            fatalError()
        }
        autofill()
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Identified by Minister", desc: InfoTips.identifiedbyMinistertoggle)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let i = self.issue, let parent = self.parentCell else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: grandParent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "Would you like to remove this issue and all actions associated to it?", yesButtonTapped: {
                    RUPManager.shared.removeIssue(issue: i)
                    parent.updateTableHeight(scrollToBottom: false, then: {})
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }
    }

    @IBAction func pasturesAction(_ sender: UIButton) {
        guard let i = issue, let grandParent = self.parentViewController as? CreateNewRUPViewController else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        let pastureNames = Options.shared.getPasturesLookup(rup: rup)
        var selected = [SelectionPopUpObject]()
        for pasture in i.pastures {
            selected.append(SelectionPopUpObject(display: pasture.name, value: pasture.name))
        }
        
        lookup.setupLive(header: "Select Pastures", onVC: grandParent, onButton: sender, selected: selected, objects: pastureNames) { (selections) in
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
    }

    @IBAction func addActionAction(_ sender: UIButton) {
        guard let i = self.issue else {return}
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        lookup.setup(objects: Options.shared.getMinistersIssueActionsOptions(), onVC: parent, onButton: sender) { (selected, selection) in
            parent.dismissPopOver()
            if selected, let option = selection {
                if let type = Reference.shared.getIssueActionType(named: option.display) {
                    i.addAction(type: type, name: option.display)
                    self.updateTableHeight(scrollToBottom: false)
                }
            }
        }
    }

    @IBAction func editTypeAction(_ sender: UIButton) {
        editType()
    }

    // MARK: Functions
    // MARK: Setup
    func setup(issue: MinisterIssue, mode: FormMode, rup: Plan, parent: MinisterIssuesTableViewCell) {
        self.rup = rup
        self.mode = mode
        self.issue = issue
        self.parentCell = parent
        detailsValue.delegate = self
        objectiveValue.delegate = self
        setUpTable()
        // style before autofill to style the switch!
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
        lookup.setup(header: "", objects: Options.shared.getMinistersIssueTypesOptions(), onVC: grandParent, onLayer: issueTypeValue.layer, inView: containerView) { (selected, selection) in
            grandParent.dismissPopOver()
            if selected, let option = selection {
                if let i = self.issue {
                    i.set(issueType: option.display)
                    self.autofill()
                }
                self.updateTableHeight(scrollToBottom: false)
            }
        }
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
            pastures = "\(pastures)"
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
        identifiedByMinisterSwitch.setOn(i.identified, animated: true)

        if self.mode == .View {
            setDefaultValueIfEmpty(field: pastureValue)
            setDefaultValueIfEmpty(field: detailsValue)
            setDefaultValueIfEmpty(field: objectiveValue)

        }

        if detailsValue.text == "" {
            switch mode {
            case .View:
                detailsValue.text = "Details not provided"
            case .Edit:
                addPlaceHolder(on: detailsValue)
            }
        }

        if objectiveValue.text == "" {
            switch mode {
            case .View:
                objectiveValue.text = "Objectives not provided"
            case .Edit:
                addPlaceHolder(on: objectiveValue)
            }
        }
    }

    func computeTableHeight() -> CGFloat {
        guard let i = self.issue else {return 0}
        return MinistersIssueActionTableViewCell.cellHeight * CGFloat(i.actions.count)
    }

    func updateTableHeight(scrollToBottom: Bool) {
        guard let parent = self.parentCell else {return}
        tableHeight.constant = computeTableHeight()
        parent.updateTableHeight(scrollToBottom: scrollToBottom) {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

    // MARK: Style
    func style() {
        styleContainer(view: containerView)
        styleSubHeader(label: issueTypeHeader)
        styleSubHeader(label: issueTypeValue)
        styleStaticField(field: pastureValue, header: pastureHeader)
        styleSubHeader(label: actionsHeader)
        styleSubHeader(label: identifiedByMinisterLabel)
        identifiedByMinisterSwitch.onTintColor = Colors.switchOn
        styleSubHeader(label: noteLabel)
        noteLabel.font = Fonts.getPrimaryBold(size: 12)
        switch self.mode {
        case .View:
            identifiedByMinisterSwitch.isEnabled = false
            addPastureButtonWidth.constant = 0
            optionsButton.alpha = 0
            addButton.alpha = 0
            addPasturesButton.alpha = 0
            editButton.alpha = 0
            pasturesButton.isUserInteractionEnabled = false
            styleTextviewInputFieldReadOnly(field: detailsValue, header: detailsHeader)
            styleTextviewInputFieldReadOnly(field: objectiveValue, header: objectiveHeader)
        case .Edit:
            styleFillButton(button: addButton)
            makeCircle(button: addPasturesButton)
            addShadow(layer: addPasturesButton.layer)
            styleTextviewInputField(field: detailsValue, header: detailsHeader)
            styleTextviewInputField(field: objectiveValue, header: objectiveHeader)
            if detailsValue.text == PlaceHolders.MinistersIssuesAndActions.details {
                detailsValue.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }

            if objectiveValue.text == PlaceHolders.MinistersIssuesAndActions.objective {
                detailsValue.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
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
            if textView.text != PlaceHolders.MinistersIssuesAndActions.details {
                i.set(details: textView.text)
            }
        case objectiveValue:
            if textView.text != PlaceHolders.MinistersIssuesAndActions.objective {
                i.set(objective: textView.text)
            }
        default:
            return
        }

        if textView.text == "" {
            addPlaceHolder(on: textView)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case detailsValue:

            if textView.text == PlaceHolders.MinistersIssuesAndActions.details {
                removePlaceHolder(on: textView)
            }
        case objectiveValue:

            if textView.text == PlaceHolders.MinistersIssuesAndActions.objective {
                removePlaceHolder(on: textView)
            }
        default:
            return
        }
    }

    func addPlaceHolder(on textView: UITextView) {
        switch textView {
        case detailsValue:
            textView.text = PlaceHolders.MinistersIssuesAndActions.details
        case objectiveValue:
            textView.text = PlaceHolders.MinistersIssuesAndActions.objective
        default:
            return
        }
        textView.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder(on textView: UITextView) {
        textView.text = ""
        textView.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
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
        cell.setup(action: i.actions[indexPath.row], parentCell: self, mode: mode, rup: rup)
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
