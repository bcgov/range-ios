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
class PastureTableViewCell: BaseFormCell {

    // MARK: Variables
    var parentCell: PasturesTableViewCell?
    var pasture: Pasture?

    // MARK: Outlets
    @IBOutlet weak var pastureNameHeader: UILabel!
    @IBOutlet weak var pastureNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    @IBOutlet weak var pastureNotesTextField: UITextView!
    @IBOutlet weak var pastureNotesHeader: UILabel!
    @IBOutlet weak var aumsField: UITextField!
    @IBOutlet weak var deductionFIeld: UITextField!
    @IBOutlet weak var graceDaysField: UITextField!

    @IBOutlet weak var fieldHeight: NSLayoutConstraint!

    @IBOutlet weak var graceDaysHeader: UILabel!
    @IBOutlet weak var pldHeader: UILabel!
    @IBOutlet weak var aumHeader: UILabel!

    @IBOutlet weak var options: UIButton!

    @IBOutlet weak var addPlantCommunityButton: UIButton!
    @IBOutlet weak var addPlantCommunityButtonHeight: NSLayoutConstraint!

    @IBOutlet weak var plantCommunitiesLabel: UILabel!

    @IBOutlet weak var pastureNameButton: UIButton!
    @IBOutlet weak var pastureNameEditButton: UIButton!
    // Remove this button
    @IBOutlet weak var pastureNameEdit: UIButton!


    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Outlet Actions
    @IBAction func pldToolTipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Private Land Deduction", desc: InfoTips.privateLandDeduction)
    }

    @IBAction func allowableAUMTipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Allowable AUMs", desc: InfoTips.allowableAUMs)
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        //        parent.showTooltip(on: sender, title: "Plant Community", desc: tooltipPlantCommunitiesDescription)
    }

    @IBAction func editNameAction(_ sender: UIButton) {
        editName()
    }

    @IBAction func beginEditAUM(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @IBAction func beginEditDeduction(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @IBAction func beginEditGraceDays(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @objc private func selectRange(sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    @IBAction func addPlantCommunityAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        
        lookup.setup(objects: Options.shared.getPlanCommunityTypeOptions(), onVC: parent, onButton: button) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                let pc = PlantCommunity()
                pc.name = option.display
                do {
                    let realm = try Realm()
                    try realm.write {
                        self.pasture?.plantCommunities.append(pc)
                    }
                } catch _ {
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
                }
                self.updateTableHeight()
            }
        }
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
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }

        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.plan)!)
    }

    @IBAction func landDeductionChanged(_ sender: UITextField) {
        do {
            let realm = try Realm()
            try realm.write {
                if (deductionFIeld.text?.isDouble)! {
                    let doubleValue = Double(deductionFIeld.text!)!
                    let toInt = Int(doubleValue)
                    self.pasture?.privateLandDeduction = Double(toInt)
                    deductionFIeld.textColor = UIColor.black
                } else {
                    deductionFIeld.textColor = UIColor.red
                    self.pasture?.privateLandDeduction = 0.0
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.plan)!)
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
                    self.pasture?.graceDays = 3
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.plan)!)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let past = self.pasture, let parent = parentCell, let grandParent = parent.parentViewController as? CreateNewRUPViewController else {return}

        // View manager instance to grab options view controller
        let vm = ViewManager()
        let optionsVC = vm.options

        // create options for module, in this case copy and delete
        let options: [Option] = [Option(type: .Copy, display: "Copy"),Option(type: .Delete, display: "Delete")]

        // set up and handle call back
        optionsVC.setup(options: options, onVC: grandParent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "Deleting pasture \(past.name) will also remove all schedule elements associated with it", yesButtonTapped: {
                    RUPManager.shared.deletePasture(pasture: past)
                    parent.updateTableHeight()
                }, noButtonTapped: {})

            case .Copy:
                self.duplicate()
            }
        }
    }

    @IBAction func graceDaysInfo(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Grace Days", desc: PlaceHolders.Pasture.graceDays)
    }

    // MARK: Setup
    func setup(mode: FormMode, pasture: Pasture, plan: Plan, pastures: PasturesTableViewCell) {
        style()
        self.parentCell = pastures
        self.mode = mode
        self.pasture = pasture
        self.plan = plan
        self.plan = pastures.plan
        autofill()
        setupTable()
        style()
        self.pastureNotesTextField.delegate = self
        switch mode {
        case .View:
            options.isEnabled = false
            options.alpha = 0
        case .Edit:
            options.isEnabled = true
            options.alpha = 1
        }
    }

    func autofill() {
        guard let p = self.pasture else {return}

        self.pastureNameLabel.text = p.name
        self.aumsField.text = "\(p.allowedAUMs)"
        self.deductionFIeld.text = "\(Int(p.privateLandDeduction))"
        self.graceDaysField.text = "\(p.graceDays)"

        self.pastureNotesTextField.text = p.notes

        if p.allowedAUMs == -1 {
            self.aumsField.text = "not set"
        }

        if pastureNotesTextField.text == "" {
            switch mode {
            case .View:
                self.pastureNotesTextField.text = "Notes not provided"
            case .Edit:
                addPlaceHolder()
            }
        }

        let padding = 5
        tableHeight.constant = CGFloat((p.plantCommunities.count) * PlantCommunityTableViewCell.cellHeight + padding)
    }

    // MARK: Options
    func editName(){
        guard let pasture = self.pasture, let plan = self.plan else {return}
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Pasture Name", taken: Options.shared.getPastureNames(rup: plan)) { (name) in
            if name != "" {
                pasture.setName(string: name)
                self.autofill()
            }
        }
    }

    func duplicate() {
        guard let pasture = self.pasture, let parent = parentCell, let plan = self.plan else {return}
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Pasture Name", taken: Options.shared.getPastureNames(rup: plan)) { (name) in
            if name != "", let refetchedPlan = self.refetchPlan() {
                refetchedPlan.addPasture(cloneFrom: pasture, withName: name)
                self.plan = refetchedPlan
                parent.updateTableHeight()
            }
        }
    }

    // MARK: Styles
    func style() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: aumsField, header: aumHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: deductionFIeld, header: pldHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: graceDaysField, header: graceDaysHeader, height: fieldHeight)
            styleTextviewInputFieldReadOnly(field: pastureNotesTextField, header: pastureNotesHeader)
            addPlantCommunityButton.alpha = 0
            pastureNameButton.isEnabled = false
            pastureNameEditButton.isEnabled = false
            pastureNameEdit.isEnabled = false
        //            addPlantCommunityButtonHeight.constant = 0
        case .Edit:
            styleInputField(field: aumsField, header: aumHeader, height: fieldHeight)
            styleInputField(field: deductionFIeld, header: pldHeader, height: fieldHeight)
            styleInputField(field: graceDaysField, header: graceDaysHeader, height: fieldHeight)
            styleTextviewInputField(field: pastureNotesTextField, header: pastureNotesHeader)
            styleFillButton(button: addPlantCommunityButton)
            pastureNameButton.isEnabled = true
            pastureNameEditButton.isEnabled = true
            pastureNameEdit.isEnabled = true

            addPlantCommunityButton.alpha = 1
            if pastureNotesTextField.text == PlaceHolders.Pasture.notes {
                pastureNotesTextField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
        }
        styleContainer(view: containerView)
        styleSubHeader(label: pastureNameHeader)
        styleSubHeader(label: pastureNameLabel)
        styleSubHeader(label: plantCommunitiesLabel)
    }

    // MARK: Dynamic Cell Height
    func getCellHeight() -> CGSize {
        return self.frame.size
    }

    func refreshPastureObject() {
        guard let p = self.pasture else {return}
        do {
            let realm = try Realm()
            if let refetch = realm.objects(Pasture.self).filter("localId = %@", p.localId).first {
                self.pasture = refetch
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func updateTableHeight() {
        refreshPastureObject()
        tableHeight.constant = computeHeight()
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        if let parent = parentCell {
            parent.updateTableHeight()
        }
    }

    func computeHeight() -> CGFloat {
        let padding = 5
        guard let p = self.pasture else {return CGFloat(padding)}
        return CGFloat((p.plantCommunities.count) * PlantCommunityTableViewCell.cellHeight + padding)
    }
}

// MARK: TableView
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
        guard let pasture = self.pasture, let plan = self.plan else {return cell}
        cell.setup(mode: self.mode, plantCommunity:pasture.plantCommunities[indexPath.row], pasture: pasture, plan: plan, parentCellReference: self)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.pasture?.plantCommunities.count)!
    }

}

// MARK: Notes
extension PastureTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == PlaceHolders.Pasture.notes {
            removePlaceHolder()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let pasture = self.pasture else {return}

        if textView.text != PlaceHolders.Pasture.notes {
            do {
                let realm = try Realm()
                try realm.write {
                    pasture.notes = textView.text
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }

        if textView.text == "" {
            addPlaceHolder()
        }
    }

    func addPlaceHolder() {
        pastureNotesTextField.text = PlaceHolders.Pasture.notes
        pastureNotesTextField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder() {
        pastureNotesTextField.text = ""
        pastureNotesTextField.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
    }
}
