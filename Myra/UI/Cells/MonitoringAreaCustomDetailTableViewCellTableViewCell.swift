//
//  MonitoringAreaCustomDetailTableViewCellTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MonitoringAreaCustomDetailTableViewCellTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 66
    let freeTextOption = "Custom"

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?
    var indicatorPlant: IndicatorPlant?
    var parentCellReference: MonitoringAreaCustomDetailsTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var rightField: UITextField!
    @IBOutlet weak var leftField: UITextField!
    @IBOutlet weak var rightFIeldButton: UIButton!
    @IBOutlet weak var leftFieldButton: UIButton!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var leftFieldDropDown: UIButton!
    @IBOutlet weak var optionsButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func leftFieldAction(_ sender: UIButton) {
        guard let plant = self.indicatorPlant, let parent = self.parentReference, let parentCell = self.parentCellReference, let section = parentCell.section else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        var options = Options.shared.getIndicatorPlantLookup()
        lookup.setup(objects: options, onVC: parent, onButton: leftFieldDropDown) { (accepted, selection) in
//            lookup.dismiss(animated: true, completion: nil)
            if accepted, let option = selection, let species = Reference.shared.getIndicatorPlant(named: option.display) {
                plant.setType(string: option.display)
                switch section {
                case .RangeReadiness:
                    plant.setDetail(text: "\(species.leafStage)")
                case .StubbleHeight:
                    plant.setDetail(text: "\(species.stubbleHeight)")
                case .ShrubUse:
                    plant.setDetail(text: "\(species.annualGrowth)")
                }
                self.autofill()
            }
        }
    }

    @IBAction func rightFieldAction(_ sender: UIButton) {}

    @IBAction func rightFieldValueChanged(_ sender: UITextField) {
        guard let ip = self.indicatorPlant, let text = sender.text else {return}
        ip.setDetail(text: text)
        checkRightFieldValidity()
    }

    @IBAction func rightFieldValueEndEditing(_ sender: UITextField) {
        guard let ip = self.indicatorPlant, let text = sender.text else {return}
        ip.setDetail(text: text)
        checkRightFieldValidity()
        autofill()
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let plant = self.indicatorPlant, let parent = self.parentReference, let parentCell = self.parentCellReference else {return}
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete")]
        optionsVC.setup(options: options, onVC: parent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                parent.showAlert(title: "Would you like to delete this indicator plant?", description: "", yesButtonTapped: {
                    RealmRequests.deleteObject(plant)
                    parentCell.updateHeight()
                }, noButtonTapped: {
                    
                })
            case .Copy:
                print("not yet implemented")
                //                self.duplicate()
            }
        }
    }

    func checkRightFieldValidity() {
        guard let ip = self.indicatorPlant, let text = rightField.text else {return}
        if ip.type != freeTextOption && !text.isDouble {
            rightField.textColor = Colors.accent.red
        } else {
            rightField.textColor = Colors.inputText
        }
    }
    
    func setup(mode: FormMode, indicatorPlant: IndicatorPlant, plantCommunity: PlantCommunity, parentReference: PlantCommunityViewController, parentCellReference: MonitoringAreaCustomDetailsTableViewCell) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.parentReference = parentReference
        self.indicatorPlant = indicatorPlant
        self.parentCellReference = parentCellReference
        self.style()
        self.autofill()
    }

    func autofill() {
        guard let ip = self.indicatorPlant, let parentCell = self.parentCellReference, let section = parentCell.section else {return}
        self.leftField.text = ip.type

        if section == .ShrubUse, ip.getDetail().isDouble, let doubleValue = Double(ip.getDetail()) {
            let intValue = Int(doubleValue)
            self.rightField.text = "\(intValue)"
        } else {
            self.rightField.text = ip.getDetail()
        }
        if ip.type == freeTextOption {
            switch section {
            case .RangeReadiness:
                rightField.placeholder = "Enter a leaf stage criteria here..."
            case .StubbleHeight:
                rightField.placeholder = "Enter a stubble height criteria (in cm) here..."
            case .ShrubUse:
                rightField.placeholder = "Enter % of current annual growth here..."
            }
        } else {
            rightField.placeholder = ""
        }
        checkRightFieldValidity()
    }

    func style() {
        rightFIeldButton.alpha = 0
        switch mode {
        case .View:
            leftFieldButton.isUserInteractionEnabled = false
            rightFIeldButton.isUserInteractionEnabled = false
            optionsButton.isUserInteractionEnabled = false
            optionsButton.alpha = 0
            leftFieldDropDown.isUserInteractionEnabled = false
            leftFieldDropDown.alpha = 0
            styleInputField(field:leftField, editable: false, height: fieldHeight)
            styleInputField(field:rightField, editable: false, height: fieldHeight)
        case .Edit:
            styleInput(input: rightField, height: fieldHeight)
            styleInput(input: leftField, height: fieldHeight)
        }
    }
    
}
