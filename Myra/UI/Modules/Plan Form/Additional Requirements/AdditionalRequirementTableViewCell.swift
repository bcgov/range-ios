//
//  AdditionalRequirementTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class AdditionalRequirementTableViewCell: BaseFormCell {

    static let cellHeight:CGFloat = 271

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

    var additionalRequirementsParent: AdditionalRequirementsTableViewCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        detailsField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func categoryAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController, let req = self.additionalRequirement else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: Options.shared.getAdditionalRequirementLookup(), onVC: parent, onButton: sender, otherEnabled: false) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                req.setValue(category: option.display)
                self.autoFill()
            }
        }
    }

    @IBAction func urlAction(_ sender: UITextField) {
        guard let req = self.additionalRequirement else {return}
        req.setValue(url: sender.text)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController, let req = self.additionalRequirement, let parentCell = self.additionalRequirementsParent else {return}
        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Copy, display: "Copy"),Option(type: .Delete, display: "Delete")]

        optionsVC.setup(options: options, onVC: parent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                parent.showAlert(title: "Are you sure?", description: "Would you like to delete this Requirement?", yesButtonTapped: {
                    RealmRequests.deleteObject(req)
                    parentCell.updateTableHeight(scrollToBottom: false)
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }
    }

    func duplicate() {
        guard let req = self.additionalRequirement, let plan = self.plan, let parentCell = self.additionalRequirementsParent else {return}
        do {
            let realm = try Realm()
            try realm.write {
                plan.additionalRequirements.append(req.clone())
                NewElementAddedBanner.shared.show()
            }
        } catch {
            fatalError()
        }
        parentCell.updateTableHeight(scrollToBottom: true)
    }

    func setup(mode: FormMode, object: AdditionalRequirement, plan: Plan, parentCell: AdditionalRequirementsTableViewCell) {
        self.additionalRequirementsParent = parentCell
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

        if detailsField.text == "" {
            switch mode {
            case .View:
                detailsField.text = "Details not provided"
            case .Edit:
                addPlaceHolder()
            }
        }

    }

    func style() {
        guard let _ = self.container else {return}
        roundCorners(layer: container.layer) 
        addShadow(to: container.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 3)
        styleFieldHeader(label: categoryHeader)
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

            if detailsField.text == PlaceHolders.AdditionalRequirements.description {
                detailsField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
        }
    }
    
}
// MARK: Notes
extension AdditionalRequirementTableViewCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == PlaceHolders.AdditionalRequirements.description {
            removePlaceHolder()
        }

    }

    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let req = self.additionalRequirement else {return}
        if textView.text != PlaceHolders.AdditionalRequirements.description {
            req.setValue(detail: textView.text)
        }

        if textView.text == "" {
            addPlaceHolder()
        }
    }

    func addPlaceHolder() {
        detailsField.text = PlaceHolders.AdditionalRequirements.description
        detailsField.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder() {
        detailsField.text = ""
        detailsField.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
    }
}
