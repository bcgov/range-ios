//
//  ShrubUseTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ShrubUseTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?

    // MARK: Outlets
    @IBOutlet weak var sectionHeader: UILabel!
    @IBOutlet weak var sectionDescription: UILabel!
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Outlet Actions
    @IBAction func beganEditing(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @IBAction func textChanged(_ sender: UITextField) {
        guard let plantCommunity = self.plantCommunity, let text = field.text else {return}
        if text.isDouble {
            plantCommunity.setShrubUse(to: Double(text) ?? 0)
            field.textColor = defaultInputFieldTextColor()
        } else {
            field.textColor = Colors.accent.red
        }
    }

    @objc private func selectRange(sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    // MARK: Setup
    func setup(with plantCommunity: PlantCommunity, mode: FormMode) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        style()
        autofill()
    }

    func autofill() {
        guard let plantCommunity = self.plantCommunity else {return}
        self.field.text = "\(Int(plantCommunity.shrubUse))"
    }

    // MARK: Style
    func style() {
        styleFieldHeader(label: fieldHeader)
        styleInputField(field: field, editable: self.mode == .Edit, height: fieldHeight)
        styleInputField(field: field, header: fieldHeader, height: fieldHeight)
        styleSubHeader(label: sectionHeader)
        sectionDescription.font = Fonts.getPrimary(size: 17)
        styleContainer(view: container)
    }

}
