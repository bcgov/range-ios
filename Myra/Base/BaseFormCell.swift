//
//  BaseFormCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-01.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseFormCell: UITableViewCell, Theme {

    // MARK: Variables
    var rup: RUP = RUP()
    var mode: FormMode = .View

    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(_:)), name: .screenOrientationChanged, object: nil)
    }

    @objc func orientationChanged(_ notification: NSNotification) {

    }

    // MARK: Cell Setup
    func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
    }

    func setDefaultValueIfEmpty(field: UITextView) {
        if field.text == "" {
            field.text = "Not provided."
        }
    }

    func setDefaultValueIfEmpty(field: UILabel) {
        if field.text == "" {
            field.text = "Not provided."
        }
    }
}

extension BaseFormCell: UITextFieldDelegate {

    // LIMIT max characters of text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
