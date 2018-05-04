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

    // MARK: Constants
    let plantCommunityCellHeight = 100

    // MARK: Variables
    var pastures: PasturesTableViewCell?
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

    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        loaded = true
    }

    // MARK: Outlet Actions
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
                    self.pasture?.graceDays = 3
                }
            }
        } catch _ {
            fatalError()
        }
        RUPManager.shared.updateSchedulesForPasture(pasture: pasture!, in: (pastures?.rup)!)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let past = self.pasture, let parent = pastures else {return}
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
            switch option.type {
            case .Delete:
                print("delete")
                RUPManager.shared.deletePasture(pasture: past)
                parent.updateTableHeight()
            case .Copy:
                print("copy")
                self.duplicate()
            }
            optionsVC.dismiss(animated: true, completion: nil)
        }

        // display on parent
        grandParent .showPopOver(on: sender , vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)

    }

    // MARK: Functions
    func setup(mode: FormMode, pasture: Pasture, pastures: PasturesTableViewCell) {
        self.pastures = pastures
        self.mode = mode
        self.pasture = pasture
        self.pastureNameLabel.text = pasture.name
        self.rup = pastures.rup
        autofill()
        setupTable()
        self.pastureNotesTextField.delegate = self
        style()
    }

    func autofill() {
        if let allowedAumsVal = pasture?.allowedAUMs {
            self.aumsField.text = "\(allowedAumsVal)"
        }

        if let pldVal = pasture?.privateLandDeduction {
            let intPldVal = Int(pldVal)
            self.deductionFIeld.text = "\(intPldVal)"
        }

        if let graceDaysVal = pasture?.graceDays {
            self.graceDaysField.text = "\(graceDaysVal)"
        }
        
        self.pastureNotesTextField.text = pasture?.notes
    }

    func getCellHeight() -> CGSize {
        return self.frame.size
    }

    func updateTableHeight() {
        let padding = 5
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        tableHeight.constant = CGFloat((self.pasture?.plantCommunities.count)! * plantCommunityCellHeight + padding)
        if let parent = pastures {
            parent.updateTableHeight()
        }
    }

    func duplicate() {
        guard let past = self.pasture, let parent = pastures else {return}
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
        styleInputField(field: aumsField, header: aumHeader, height: fieldHeight)
        styleInputField(field: deductionFIeld, header: pldHeader, height: fieldHeight)
        styleInputField(field: graceDaysField, header: graceDaysHeader, height: fieldHeight)
        styleInputField(field: pastureNotesTextField, header: pastureNotesHeader)
        styleContainer(view: containerView)
        styleSubHeader(label: pastureNameHeader)
        styleSubHeader(label: pastureNameLabel)
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
        cell.setup(mode: .Create, plantCommunity: (self.pasture?.plantCommunities[indexPath.row])!)
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
