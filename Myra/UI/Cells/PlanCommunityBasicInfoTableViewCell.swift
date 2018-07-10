//
//  PlanCommunityBasicInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func aspectAction(_ sender: UIButton) {
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = RUPManager.shared.getPlantCommunityElevationLookup()
        lookup.setup(objects: options) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                self.aspectField.text = selection.display
            }
        }
        grandParent.showPopUp(vc: lookup, on: sender)
    }

    @IBAction func elevationAction(_ sender: UIButton) {
        let grandParent = self.parentViewController as! PlantCommunityViewController
        let vm = ViewManager()
        let lookup = vm.lookup
        let options = RUPManager.shared.getPlantCommunityAspectLookup()
        lookup.setup(objects: options) { (selected, option) in
            lookup.dismiss(animated: true, completion: nil)
            if let selection = option {
                self.elevationField.text = selection.display
            }

        }
        grandParent.showPopUp(vc: lookup, on: sender)
    }


    // MARK: Setup
    func setup(mode: FormMode, plantCommunity: PlantCommunity) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        style()
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
