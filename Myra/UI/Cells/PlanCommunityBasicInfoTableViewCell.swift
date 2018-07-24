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

class PlanCommunityBasicInfoTableViewCell: UITableViewCell, Theme {

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

    // custom radio
    /*
    @IBOutlet weak var actionsRadioLeftView: UIView!
    @IBOutlet weak var actionsRadioRightView: UIView!
    @IBOutlet weak var actionsRadioLeftLabel: UILabel!
    @IBOutlet weak var actionsRadioRightLabel: UILabel!
    */

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
    @IBAction func aspectAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let textEntry = vm.textEntry
        textEntry.setup(on: parent, header: "Aspect") { (accepted, value) in
            if accepted {
                do {
                    let realm = try Realm()
                    let aCommunity = realm.objects(PlantCommunity.self).filter("localId = %@", pc.localId).first!
                    try realm.write {
                        aCommunity.aspect = value
                    }
                    self.plantCommunity = aCommunity
                } catch _ {
                    fatalError()
                }
                self.autofill()
            }
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
            fatalError()
        }
        self.autofill()
    }

    @IBAction func elevationAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = RUPManager.shared.getPlantCommunityElevationLookup()
        lookup.setup(objects: options, onVC: grandParent, onButton: sender) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                do {
                    let realm = try Realm()
                    try realm.write {
                        pc.elevation = selection.display
                    }
                } catch _ {
                    fatalError()
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
        let options = RUPManager.shared.getPlantCommunityPurposeOfActionsLookup()
        lookup.setup(objects: options, onVC: grandParent, onButton: sender) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                if selection.display.lowercased() == "clear" {
                    grandParent.showAlert(title: "Would you like to remove the purpose of actions?", description: "This will also remove all Plant Community Actions for this Plant Community", yesButtonTapped: {
                        pc.clearPurposeOfAction()
                        self.autofill()
                        self.reloadParent()
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
                        fatalError()
                    }
                    self.autofill()
                    self.reloadParent()
                }
            }
        }
    }

    /*
    @IBAction func leftRadioOn(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        var reloadFlag = false
        if pc.purposeOfAction == "" {
            reloadFlag = true
        }
        do {
            let realm = try Realm()
            try realm.write {
                pc.purposeOfAction = "Establish"
                pc.isPurposeOfActionEstablish = true
            }
        } catch _ {
            fatalError()
        }
        establishOn()
        if reloadFlag {
            reloadParent()
        }
    }

    @IBAction func rightRadioOn(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        var reloadFlag = false
        if pc.purposeOfAction == "" {
            reloadFlag = true
        }
        do {
            let realm = try Realm()
            try realm.write {
                pc.purposeOfAction = "Maintain"
                pc.isPurposeOfActionEstablish = false
            }
        } catch _ {
            fatalError()
        }
        maintainOn()
        if reloadFlag {
            reloadParent()
        }
    }
    */

    @IBAction func communityURLChanged(_ sender: UITextField) {
        guard let pc = self.plantCommunity, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                pc.communityURL = text
            }
        } catch _ {
            fatalError()
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
//        if pc.purposeOfAction == "" {
//            radioOff()
//        } else if pc.isPurposeOfActionEstablish {
//            establishOn()
//        } else {
//            maintainOn()
//        }
    }

    // MARK: Style
    func style() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: purposeOfActionsField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: plantCommunityField, header: plantCommunityNotesHeader)
        case .Edit:
            styleInputField(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputField(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputField(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputField(field: purposeOfActionsField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputField(field: plantCommunityField, header: plantCommunityNotesHeader)
        }
    }

    /*
    func maintainOn() {
        radioOff()
        actionsRadioRightView.backgroundColor = defaultFillButtonBackground()
        actionsRadioRightView.layer.borderColor = defaultFillButtonBorderColor()
        actionsRadioRightLabel.textColor = defaultFillButtonTitleColor()
    }

    func establishOn() {
        radioOff()
        actionsRadioLeftView.backgroundColor = defaultFillButtonBackground()
        actionsRadioLeftView.layer.borderColor = defaultFillButtonBorderColor()
        actionsRadioLeftLabel.textColor = defaultFillButtonTitleColor()

    }

    func radioOff() {
        actionsRadioLeftView.backgroundColor = defaultHollowButtonBackground()
        actionsRadioLeftView.layer.borderWidth = 1
        actionsRadioLeftView.layer.borderColor = defaultHollowButtonBorderColor()
        actionsRadioLeftLabel.textColor = defaultHollowButtonTitleColor()
        actionsRadioLeftLabel.font = defaultSectionSubHeaderFont()
        actionsRadioLeftLabel.font = Fonts.getPrimaryHeavy(size: 12)

        actionsRadioRightView.backgroundColor = defaultHollowButtonBackground()
        actionsRadioRightView.layer.borderWidth = 1
        actionsRadioRightView.layer.borderColor = defaultHollowButtonBorderColor()
        actionsRadioRightLabel.textColor = defaultHollowButtonTitleColor()
        actionsRadioRightLabel.font = defaultSectionSubHeaderFont()
        actionsRadioRightLabel.font = Fonts.getPrimaryHeavy(size: 12)
    }
    */

    func reloadParent() {
        guard let parent = self.parentReference else {return}
        parent.reload(reloadData: true)
    }
}

// MARK: Notes
extension PlanCommunityBasicInfoTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let pc = self.plantCommunity, let text = textView.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                pc.notes = text
            }
        } catch _ {
            fatalError()
        }
    }
}
