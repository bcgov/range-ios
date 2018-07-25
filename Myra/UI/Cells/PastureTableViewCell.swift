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
    var loaded: Bool = false

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
    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        loaded = true
    }

    // MARK: Outlet Actions

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
        
        lookup.setup(objects: RUPManager.shared.getPlanCommunityTypeOptions(), onVC: parent, onButton: button) { (selected, selection) in
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
                    fatalError()
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
            fatalError()
        }

        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.rup)!)
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
            fatalError()
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.rup)!)
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
            fatalError()
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (parentCell?.rup)!)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let past = self.pasture, let parent = parentCell else {return}
        // reference to parent's parent
        /* note:
         technically if you do self.parent you get the same result.
         but for clarity, this makes more sense since this is a cell in a tableview cell.
        */
        let grandParent = parent.parentViewController as! CreateNewRUPViewController

        // View manager instance to grab options view controller
        let vm = ViewManager()
        let optionsVC = vm.options

        // create options for module, in this case copy and delete
        let options: [Option] = [Option(type: .Copy, display: "Copy"),Option(type: .Delete, display: "Delete")]

        // set up and handle call back
        optionsVC.setup(options: options) { (option) in
            optionsVC.dismiss(animated: true, completion: nil)
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

        // display on parent
        grandParent.showPopOver(on: sender , vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)

    }

    func editName(){
        guard let past = pasture else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let textEntry = vm.textEntry
        textEntry.setup(on: grandParent, header: "Pasture Name") { (accepted, name) in
            if accepted {
                do {
                    let realm = try Realm()
                    try realm.write {
                        past.name = name
                    }
                } catch _ {
                    fatalError()
                }
            }
        }
    }

    // MARK: Functions
    func setup(mode: FormMode, pasture: Pasture, pastures: PasturesTableViewCell) {
        self.parentCell = pastures
        self.mode = mode
        self.pasture = pasture
        self.pastureNameLabel.text = pasture.name
        self.rup = pastures.rup
        autofill()
        setupTable()
        self.pastureNotesTextField.delegate = self
        style()
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

        self.aumsField.text = "\(p.allowedAUMs)"
        self.deductionFIeld.text = "\(Int(p.privateLandDeduction))"
        self.graceDaysField.text = "\(p.graceDays)"

        self.pastureNotesTextField.text = p.notes

        if p.allowedAUMs == -1 {
            self.aumsField.text = "not set"
        }

        if self.mode == .View && self.pastureNotesTextField.text == "" {
            self.pastureNotesTextField.text = "Notes not provided"
        }

        let padding = 5
        tableHeight.constant = CGFloat((p.plantCommunities.count) * PlantCommunityTableViewCell.cellHeight + padding)
    }

    func getCellHeight() -> CGSize {
        return self.frame.size
    }

    func updateTableHeight() {
        guard let p = self.pasture else {return}
        do {
            let realm = try Realm()
            if let refetch = realm.objects(Pasture.self).filter("localId = %@", p.localId).first {
                self.pasture = refetch
            }
        } catch _ {
            fatalError()
        }

        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        let padding = 5
        tableHeight.constant = CGFloat((p.plantCommunities.count) * PlantCommunityTableViewCell.cellHeight + padding)
        if let parent = parentCell {
            parent.updateTableHeight()
        }
    }

    func duplicate() {
        guard let past = self.pasture, let parent = parentCell else {return}
        let grandParent = parent.parentViewController as! CreateNewRUPViewController
        grandParent.promptInput(title: "Pasture Name", accept: .String, taken: RUPManager.shared.getPastureNames(rup: rup)) { (done, name) in
            if done {
                let newPasture = Pasture()
                newPasture.name = name
                RUPManager.shared.copyPasture(from: past, to: newPasture)
                do {
                    let realm = try Realm()
                    let aRup = realm.objects(RUP.self).filter("localId = %@", self.rup.localId).first!
                    try realm.write {
                        aRup.pastures.append(newPasture)
                        realm.add(newPasture)
                    }
                    self.rup = aRup
                    parent.updateTableHeight()
                } catch _ {
                    fatalError()
                }
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
//            addPlantCommunityButtonHeight.constant = 0
        case .Edit:
            styleInputField(field: aumsField, header: aumHeader, height: fieldHeight)
            styleInputField(field: deductionFIeld, header: pldHeader, height: fieldHeight)
            styleInputField(field: graceDaysField, header: graceDaysHeader, height: fieldHeight)
            styleTextviewInputField(field: pastureNotesTextField, header: pastureNotesHeader)
            styleHollowButton(button: addPlantCommunityButton)
        }

        styleContainer(view: containerView)
        styleSubHeader(label: pastureNameHeader)
        styleSubHeader(label: pastureNameLabel)
        styleSubHeader(label: plantCommunitiesLabel)

        // TEMP - HIDE PLANT COMMUNITY
//        addPlantCommunityButton.alpha = 0
//        addPlantCommunityButtonHeight.constant = 0
//        plantCommunitiesLabel.alpha = 0
        // END OF TEMP
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
        guard let p = self.pasture else {return cell}
        cell.setup(mode: mode, plantCommunity: (p.plantCommunities[indexPath.row]), pasture: p, parentCellReference: self)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.pasture?.plantCommunities.count)!
    }

}

// MARK: Notes
extension PastureTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        do {
            let realm = try Realm()
            try realm.write {
                self.pasture?.notes = textView.text
            }
        } catch _ {
            fatalError()
        }
    }
}
