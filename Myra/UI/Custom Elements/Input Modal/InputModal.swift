//
//  InputModal.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import UIKit

class InputModal: CustomModal {
    
    // MARK: Variables
    var header: String = ""
    var taken: [String] = [String]()
    var callBack: ((_ value: String) -> Void )?
    var acceptedPopupInput: AcceptedPopupInput = .String
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var inputHeight: NSLayoutConstraint!
    
    // MARK: Outlet Actions
    @IBAction func cancelAction(_ sender: UIButton) {
        if let callback = self.callBack {
            callback("")
            remove()
        }
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        if let callback = self.callBack, let text = input.text, validateInput(text: text) {
            callback(text)
            remove()
        }
    }
    
    @IBAction func inputChanged(_ sender: UITextField) {
        if let text = sender.text, validateInput(text: text) {
            return
        }
    }
    
    
    // MARK: Validations
    func invalidInput(message: String) {
        titleLabel.text = message
        titleLabel.textColor = UIColor.red
    }
    
    func validInput() {
        titleLabel.text = header
        styleFieldHeader(label: titleLabel)
    }
    
    func validateInput(text: String) -> Bool {
        if text.removeWhitespaces() == "" {
            invalidInput(message: "Please enter a value")
            return false
        } else {
            // value is not duplicate
            if taken.contains(text) {
                invalidInput(message: "Duplicate value")
                return false
            } else {
                // value is in correct format
                switch acceptedPopupInput {
                case .String:
                    validInput()
                    return true
                case .Double:
                    if text.isDouble {
                        validInput()
                        return true
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                case .Integer:
                    if text.isInt {
                        validInput()
                        return true
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                case .Year:
                    if text.isInt {
                        let year = Int(text) ?? 0
                        if (year > 2000) && (year < 2100) {
                            validInput()
                            return true
                        } else {
                            invalidInput(message: "Invalid Year")
                            return false
                        }
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                }
            }
        }
    }
    
    //  MARK: Entry Point
    func initialize(header: String, taken: [String]? = [String](), completion: @escaping (_ value: String) -> Void) {
        if let taken = taken {
            self.taken = taken
        }
        self.header = header
        self.callBack = completion
        setFixed(width: 350, height: 160)
        style()
        present()
        autoFill()
        IQKeyboardManager.shared.keyboardDistanceFromTextField = getDistanceFromField()
        self.input.becomeFirstResponder()
    }
    
    // MARK: Setup
    func getDistanceFromField() -> CGFloat {
        let total = self.frame.height
        
        // 15 and 8 are title lable's top and bottom constraints
        return total - (inputHeight.constant + titleLabel.frame.height + 15 + 8)
    }
    
    func autoFill() {
        self.titleLabel.text = header
    }
    
    // MARK: Style
    func style() {
        styleFieldHeader(label: titleLabel)
        styleInput(input: input, height: inputHeight)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: addButton)
        self.backgroundColor = UIColor.white
        styleModalBox()
    }
}
