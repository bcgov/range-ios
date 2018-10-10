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

    func fadeLabelMessage(label: UILabel, text: String) {
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = text
            // fade in warning text
            UIView.animate(withDuration: 0.2, animations: {
                label.textColor = Colors.accent.red
                label.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: 0.2, delay: 3, animations: {
                    // fade out text
                    label.alpha = 0
                    self.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: 0.2, animations: {
                        label.textColor = originalTextColor
                        label.alpha = 1
                        self.layoutIfNeeded()
                    })
                })
            })
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
