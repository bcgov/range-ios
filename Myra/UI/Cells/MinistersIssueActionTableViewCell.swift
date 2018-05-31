//
//  MinistersIssueActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-29.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MinistersIssueActionTableViewCell: BaseFormCell {

    // MARK: Variables
    var action: MinisterIssueAction?
    var parentCell: MinisterIssueTableViewCell?

    // MARK: Outlets
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    
    // MARK: Outlet Actions
    @IBAction func optionsAction(_ sender: UIButton) {
        guard let a = self.action, let parent = self.parentCell else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let optionsVC = vm.options
        let options: [Option] = [Option(type: .Delete, display: "Delete"), Option(type: .Delete, display: "Copy")]
        optionsVC.setup(options: options) { (selected) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch selected.type {
            case .Delete:
                grandParent.showAlert(title: "Are you sure?", description: "", yesButtonTapped: {
                    parent.deleteAction(action: a)
                }, noButtonTapped: {})
            case .Copy:
                self.duplicate()
            }
        }

        grandParent.showPopOver(on: sender, vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)

    }

    // MARK: Functions
    // MARK: Setup
    func setup(action: MinisterIssueAction, parent: MinisterIssueTableViewCell, mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        self.action = action
        self.parentCell = parent
        desc.delegate = self
        autofill()
        style()
    }

    func autofill() {
        guard let a = self.action else {return}
        self.desc.text = a.desc
        self.header.text = a.header
    }

    // MARK: Style
    func style() {
        guard let _ = self.container else {return}
        styleContainer(view: container)
        switch self.mode {
        case .View:
            optionsButton.alpha = 0
            styleTextviewInputFieldReadOnly(field: desc, header: header)
        case .Edit:
            styleTextviewInputField(field: desc, header: header)
        }
    }

    // MARK: Utilities
    func duplicate() {

    }
}

// MARK: TextView delegates
extension MinistersIssueActionTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let a = action else {return}
        a.set(desc: textView.text)
    }
}
