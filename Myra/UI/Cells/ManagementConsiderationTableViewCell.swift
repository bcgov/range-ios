//
//  ManagementConsiderationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ManagementConsiderationTableViewCell: UITableViewCell, Theme {

    static let cellHeight:CGFloat = 271

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

    var managementConsiderationsParent: ManagementConsiderationsTableViewCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        detailsField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func considerationAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController, let obj = self.managementConsideration else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: Options.shared.getManagementConsiderationLookup(), onVC: parent, onButton: sender) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        obj.consideration = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
    }
    
    @IBAction func urlAction(_ sender: UITextField) {
        guard let obj = self.managementConsideration else {return}
        obj.setValue(url: sender.text)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController, let obj = self.managementConsideration, let parentCell = self.managementConsiderationsParent else {return}
        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Copy, display: "Copy"),Option(type: .Delete, display: "Delete")]

        optionsVC.setup(options: options, onVC: parent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                parent.showAlert(title: "Are you sure?", description: "Would you like to delete this Management Consideration?", yesButtonTapped: {
                    RealmRequests.deleteObject(obj)
                    parentCell.updateTableHeight(scrollToBottom: false)
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }
    }

    func duplicate() {
        guard let obj = self.managementConsideration, let parentCell = self.managementConsiderationsParent else {return}
        do {
            let realm = try Realm()
            try realm.write {
                parentCell.rup.managementConsiderations.append(obj.clone())
                NewElementAddedBanner.shared.show()
            }
        } catch {
            fatalError()
        }
        parentCell.updateTableHeight(scrollToBottom: true)
    }

    func setup(mode: FormMode, object: ManagementConsideration, parentCell: ManagementConsiderationsTableViewCell) {
        self.managementConsiderationsParent = parentCell
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
        styleFieldHeader(label: considerationHeader)
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

// MARK: Notes
extension ManagementConsiderationTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let obj = self.managementConsideration else {return}
        obj.setValue(detail: textView.text)
    }
}
