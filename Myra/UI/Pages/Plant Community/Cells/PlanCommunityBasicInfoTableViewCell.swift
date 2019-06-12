//
//  PlanCommunityBasicInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class PlanCommunityBasicInfoTableViewCell: BaseTableViewCell {

    // MARK: Outlets
    @IBOutlet weak var aspectHeader: UILabel!
    @IBOutlet weak var aspectField: UITextField!

    @IBOutlet weak var elevationHeader: UILabel!
    @IBOutlet weak var elevationField: UITextField!

    @IBOutlet weak var plantCommunityNotesHeader: UILabel!
    @IBOutlet weak var plantCommunityField: UITextView!

    @IBOutlet weak var communityURLHeader: UILabel!
    @IBOutlet weak var communityURLField: UITextField!

    @IBOutlet weak var purposeOfActionHeader: UILabel!
    @IBOutlet weak var purposeOfActionsField: UITextField!

    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!

    @IBOutlet weak var elevationDropdown: UIButton!
    @IBOutlet weak var elevationButton: UIButton!
    @IBOutlet weak var purposeDropdown: UIButton!
    @IBOutlet weak var purposeButton: UIButton!
    
    @IBOutlet weak var approvedByMinisterHeader: UILabel!
    @IBOutlet weak var approvedByMinisterSwitch: UISwitch!
    
    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func approvedByMinisterInfo(_ sender: UIButton) {
        guard let p = parentReference else {return}
        p.showTooltip(on: sender, title: "Approved by Minister", desc: InfoTips.approvedByMinister)
    }

    @IBAction func approvedByMinisterAction(_ sender: UISwitch) {
        guard let plantCommunity = self.plantCommunity else {return}
        do {
            let realm = try Realm()
            try realm.write {
                 plantCommunity.approvedByMinister = sender.isOn
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    @IBAction func aspectFieldChanged(_ sender: UITextField) {
        guard let pc = self.plantCommunity, let text = aspectField.text else {return}
        do {
            let realm = try Realm()
            let aCommunity = realm.objects(PlantCommunity.self).filter("localId = %@", pc.localId).first!
            try realm.write {
                aCommunity.aspect = text
            }
            self.plantCommunity = aCommunity
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        self.autofill()
    }

    @IBAction func elevationAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = Options.shared.getPlantCommunityElevationLookup()
        lookup.setup(objects: options, onVC: grandParent, onButton: elevationDropdown) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                do {
                    let realm = try Realm()
                    try realm.write {
                        pc.elevation = selection.display
                    }
                } catch _ {
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
                }
                self.autofill()
            }
        }
    }

    @IBAction func purposeOfActionAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = Options.shared.getPlantCommunityPurposeOfActionsLookup()
        lookup.setup(objects: options, onVC: grandParent, onButton: purposeDropdown) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                if selection.display.lowercased() == "clear" {
                    grandParent.showAlert(title: "Would you like to remove the purpose of actions?", description: "This will also remove all Plant Community Actions for this Plant Community", yesButtonTapped: {
                        pc.clearPurposeOfAction()
                        self.autofill()
                        self.reloadPlantCommunityActions()
                        grandParent.tableView.reloadData()
                    }, noButtonTapped: {
                        return
                    })
                } else {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            pc.purposeOfAction = selection.display
                        }
                    } catch _ {
                        Logger.fatalError(message: LogMessages.databaseWriteFailure)
                    }
                    self.autofill()
                    self.reloadPlantCommunityActions() 
                }
            }
        }
    }

    @IBAction func communityURLChanged(_ sender: UITextField) {
        guard let pc = self.plantCommunity, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                pc.communityURL = text
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, parentReference: PlantCommunityViewController) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.parentReference = parentReference
        autofill()
        style()
        self.plantCommunityField.delegate = self
    }

    func autofill() {
        guard let pc = self.plantCommunity else {return}
        aspectField.text = pc.aspect
        elevationField.text = pc.elevation
        plantCommunityField.text = pc.notes
        communityURLField.text = pc.communityURL
        purposeOfActionsField.text = pc.purposeOfAction
        if pc.purposeOfAction.lowercased() == "clear" {
            purposeOfActionsField.text = ""
        }
        approvedByMinisterSwitch.isOn = pc.approvedByMinister
        if self.plantCommunityField.text.isEmpty {
            switch mode {
            case .View:
                self.plantCommunityField.text = "Description not provided"
            case .Edit:
                addPlaceHolder()
            }
        }
    }

    // MARK: Style
    func style() {
        styleFieldHeader(label: approvedByMinisterHeader)
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: purposeOfActionsField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: plantCommunityField, header: plantCommunityNotesHeader)
            elevationButton.isUserInteractionEnabled = false
            elevationDropdown.isUserInteractionEnabled = false
            purposeButton.isUserInteractionEnabled = false
            purposeDropdown.isUserInteractionEnabled = false
            purposeDropdown.alpha = 0
            elevationDropdown.alpha = 0
            approvedByMinisterSwitch.isUserInteractionEnabled = false
        case .Edit:
            styleInputField(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputField(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputField(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputField(field: purposeOfActionsField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputField(field: plantCommunityField, header: plantCommunityNotesHeader)
            if plantCommunityField.text == PlaceHolders.PlantCommunity.description {
                plantCommunityField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
        }
    }

    func reloadParent() {
        guard let parent = self.parentReference else {return}
        parent.reload(reloadData: true, then: {})
    }

    func reloadPlantCommunityActions() {
        guard let parent = self.parentReference else {return}
        parent.tableView.reloadSections([1], with: .automatic)
    }
}

// MARK: Notes
extension PlanCommunityBasicInfoTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == PlaceHolders.PlantCommunity.description {
            removePlaceHolder()
        }
    }

    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let pc = self.plantCommunity, let text = textView.text else {return}
        if textView.text != PlaceHolders.PlantCommunity.description {
            do {
                let realm = try Realm()
                try realm.write {
                    pc.notes = text
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
        plantCommunityField.text = PlaceHolders.PlantCommunity.description
        plantCommunityField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder() {
        plantCommunityField.text = ""
        plantCommunityField.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
    }
}
