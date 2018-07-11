//
//  PlantCommunityActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityActionTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 271.0

    // MARK: Variables
    var mode: FormMode = .View
    var flag = false
    var action: PastureAction?
    var parentReference: PlantCommunityViewController?

    // MARK: Outlets
//    @IBOutlet weak var noGrazeSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var actionField: UITextField!
    @IBOutlet weak var actionHeader: UILabel!
    @IBOutlet weak var noGrazePeriodLabel: UILabel!
    @IBOutlet weak var noGrazeIn: UITextField!
    @IBOutlet weak var noGrazeOut: UITextField!

    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var noGrazeStack: UIStackView!
    @IBOutlet weak var noGrazeStackHeight: NSLayoutConstraint!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func actionFieldAction(_ sender: UIButton) {
        guard let current = action, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: RUPManager.shared.getPastureActionLookup()) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        current.action = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
        parent.showPopUp(vc: lookup, on: sender)
    }

    @IBAction func noGrazePeriodBegin(_ sender: UIButton) {

    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {

    }
    

    // MARK: Setup
    func setup(mode: FormMode, action: PastureAction, parentReference: PlantCommunityViewController) {
        self.mode = mode
        self.action = action
        self.parentReference = parentReference
        style()
        autoFill()
        descriptionField.delegate = self
    }

    func autoFill() {
        guard let current = action else {return}
        self.actionField.text = current.action
        if current.action.lowercased() == "timing" {
            showNoGrazeSection()
        } else {
            hideNoGrazeSection()
        }
    }

    func hideNoGrazeSection() {
        noGrazeStackHeight.constant = 0
        noGrazeStack.alpha = 0
        animateIt()
    }

    func showNoGrazeSection() {
        noGrazeStackHeight.constant = 55
        noGrazeStack.alpha = 1
        animateIt()
    }

    func animateIt() {
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
    }

    func style() {
//        styleFieldHeader(label: noGrazePeriodLabel)
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: actionField, header: actionHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputFieldReadOnly(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputFieldReadOnly(field: descriptionField, header: descriptionHeader)
        case .Edit:
            styleInputField(field: actionField, header: actionHeader, height: inputFieldHeight)
            styleInputField(field: noGrazeIn, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleInputField(field: noGrazeOut, header: noGrazePeriodLabel, height: inputFieldHeight)
            styleTextviewInputField(field: descriptionField, header: descriptionHeader)
        }
    }
}

// MARK: Notes
extension PlantCommunityActionTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let act = self.action, let text = textView.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                act.details = text
            }
        } catch _ {
            fatalError()
        }
    }
}
