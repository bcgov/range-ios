//
//  ManagementConsiderationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ManagementConsiderationTableViewCell: UITableViewCell, Theme {

    static let cellHeight:CGFloat = 255

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var considerationHeader: UILabel!
    @IBOutlet weak var considerationField: UITextField!
    @IBOutlet weak var detailsHeader: UILabel!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var urlHeader: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var considerationButton: UIButton!
    @IBOutlet weak var considerationDropdownButton: UIButton!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsButton: UIButton!

    var managementConsideration: ManagementConsideration?
    var mode: FormMode = .View

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func considerationAction(_ sender: UIButton) {

    }

    func setup(mode: FormMode, object: ManagementConsideration) {
        self.mode = mode
        self.managementConsideration = object
        style()
        autoFill()
    }

    func autoFill() {
        guard let managementConsideration = self.managementConsideration else {return}
        self.considerationField.text = managementConsideration.consideration
        self.detailsField.text = managementConsideration.detail
        self.urlField.text = managementConsideration.url
    }

    func style() {
        guard let _ = self.container else {return}
        roundCorners(layer: container.layer)
        addShadow(to: container.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 3)
        styleHeader(label: considerationHeader)
        styleInputField(field: considerationField, editable: (mode == .Edit), height: fieldHeight)
        switch self.mode {
        case .View:
            optionsButton.alpha = 0
            optionsButton.isEnabled = false
            considerationButton.isEnabled = false
            considerationDropdownButton.alpha = 0
            considerationDropdownButton.isEnabled = false
            detailsField.isEditable = false
            styleInputReadOnly(input: urlField, height: fieldHeight)
            styleTextviewInputFieldReadOnly(field: detailsField, header: detailsHeader)
        case .Edit:
            optionsButton.alpha = 1
            optionsButton.isEnabled = true
            considerationButton.isEnabled = true
            considerationDropdownButton.alpha = 1
            considerationDropdownButton.isEnabled = true
            detailsField.isEditable = true
            styleInput(input: urlField, height: fieldHeight)
            styleTextviewInputField(field: detailsField, header: detailsHeader)
        }
    }
}
