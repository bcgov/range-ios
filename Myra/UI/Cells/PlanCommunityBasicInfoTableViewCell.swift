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
    @IBOutlet weak var purposeOfActionField: UITextField!

    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!

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
//        guard let pc = self.plantCommunity else {return}
//        let grandParent = self.parentViewController as! PlantCommunityViewController
//        let vm = ViewManager()
//        let lookup = vm.lookup
//        let options = RUPManager.shared.getPlantCommunityElevationLookup()
//        lookup.setup(objects: options) { (selected, option) in
//            lookup.dismiss(animated: true, completion: nil)
//            if let selection = option {
//                do {
//                    let realm = try Realm()
//                    try realm.write {
//                        pc.aspect = selection.display
//                    }
//                } catch _ {
//                    fatalError()
//                }
//                self.autofill()
//            }
//        }
//        grandParent.showPopUp(vc: lookup, on: sender)


        guard let pc = self.plantCommunity, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let textEntry = vm.textEntry
        textEntry.setup { (accepted, value) in
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
                parent.removeWhiteScreen()
                textEntry.remove()
                self.autofill()
            } else {
                parent.removeWhiteScreen()
                textEntry.remove()
            }
        }
        parent.showTextEntry(vc: textEntry)
    }

    @IBAction func elevationAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity else {return}
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = RUPManager.shared.getPlantCommunityAspectLookup()
        lookup.setup(objects: options) { (selected, option) in
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
        grandParent.showPopUp(vc: lookup, on: sender)
    }


    @IBAction func purposeOfActionsChanged(_ sender: UITextField) {
        guard let pc = self.plantCommunity, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                pc.purposeOfAction = text
            }
        } catch _ {
            fatalError()
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
        purposeOfActionField.text = pc.purposeOfAction
    }

    // MARK: Style
    func style() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: purposeOfActionField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: plantCommunityField, header: plantCommunityNotesHeader)
        case .Edit:
            styleInputField(field: aspectField, header: aspectHeader, height: inputFieldHeight)
            styleInputField(field: elevationField, header: elevationHeader, height: inputFieldHeight)
            styleInputField(field: communityURLField, header: communityURLHeader, height: inputFieldHeight)
            styleInputField(field: purposeOfActionField, header: purposeOfActionHeader, height: inputFieldHeight)
            styleTextviewInputField(field: plantCommunityField, header: plantCommunityNotesHeader)
        }
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
