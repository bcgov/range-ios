//
//  AdditionalRequirementTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AdditionalRequirementTableViewCell: UITableViewCell, Theme {

    static let cellHeight:CGFloat = 255

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var categoryHeader: UILabel!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var detailsHeader: UILabel!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var urlHeader: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categoryDropdownButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!

    var additionalRequirement: AdditionalRequirement?
    var mode: FormMode = .View

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func categoryAction(_ sender: UIButton) {
        
    }

    func setup(mode: FormMode, object: AdditionalRequirement) {
        self.mode = mode
        self.additionalRequirement = object
        style()
        autoFill()
    }

    func autoFill() {
        guard let additionalRequirement = self.additionalRequirement else {return}
        self.categoryField.text = additionalRequirement.category
        self.detailsField.text = additionalRequirement.detail
        self.urlField.text = additionalRequirement.url
    }

    func style() {
        guard let _ = self.container else {return}
        roundCorners(layer: container.layer)
        addShadow(to: container.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 3)
        styleHeader(label: categoryHeader)
        styleInputField(field: categoryField, editable: (mode == .Edit), height: fieldHeight)
        switch self.mode {
        case .View:
            optionsButton.alpha = 0
            optionsButton.isEnabled = false
            categoryButton.isEnabled = false
            categoryDropdownButton.alpha = 0
            categoryDropdownButton.isEnabled = false
            detailsField.isEditable = false
            styleInputReadOnly(input: urlField, height: fieldHeight)
            styleTextviewInputFieldReadOnly(field: detailsField, header: detailsHeader)
        case .Edit:
            optionsButton.alpha = 1
            optionsButton.isEnabled = true
            categoryButton.isEnabled = true
            categoryDropdownButton.alpha = 1
            categoryDropdownButton.isEnabled = true
            detailsField.isEditable = true
            styleInput(input: urlField, height: fieldHeight)
            styleTextviewInputField(field: detailsField, header: detailsHeader)
        }
    }
    
}
