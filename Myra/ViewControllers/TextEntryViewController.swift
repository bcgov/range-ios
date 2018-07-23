//
//  TextEntryViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class TextEntryViewController: UIViewController, Theme {

    // MARK: Variables
    var parentVC: BaseViewController?
    var header: String = ""
    var value: String = ""
    var taken: [String] = [String]()
    var object: TestEntry?
    var callBack: ((_ add: Bool, _ value: String) -> Void )?
    var acceptedPopupInput: AcceptedPopupInput = .String
    var inputIsValid: Bool = false

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var inputHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        if let c = self.callBack {
            c(false, "")
            remove()
        }
    }

    @IBAction func addAction(_ sender: UIButton) {
        if let c = self.callBack, inputIsValid {
            c(true, value)
            remove()
        } else if input.text?.removeWhitespace() == "" {
            invalidInput(message: "Please enter a value")
        }
    }

    @IBAction func inputChanged(_ sender: UITextField) {
        if let text = sender.text {
            // has value
            if text.removeWhitespace() == "" {
                invalidInput(message: "Please enter a value")
                return
            } else {
                // value is not duplicate
                if taken.contains(text) {
                    invalidInput(message: "Duplicate value")
                    return
                } else {
                    // value is in correct format
                    switch acceptedPopupInput {
                    case .String:
                        self.value = text
                    case .Double:
                        if text.isDouble {
                            self.value = text
                        } else {
                            invalidInput(message: "Invalid value")
                            return
                        }
                    case .Integer:
                        if text.isInt {
                            self.value = text
                        } else {
                            invalidInput(message: "Invalid value")
                            return
                        }
                    case .Year:
                        if text.isInt {
                            let year = Int(text) ?? 0
                            if (year > 2000) && (year < 2100) {
                                self.value = text
                            } else {
                                invalidInput(message: "Invalid Year")
                                return
                            }
                        } else {
                            invalidInput(message: "Invalid value")
                            return
                        }
                    }
                }
            }
            validInput()
        }
    }

    func invalidInput(message: String) {
        inputIsValid = false
        titleLabel.text = message
        titleLabel.textColor = UIColor.red
    }

    func validInput() {
        inputIsValid = true
        titleLabel.text = header
        styleFieldHeader(label: titleLabel)
    }

    func setup(on: BaseViewController, header: String, completion: @escaping (_ add: Bool, _ value: String) -> Void) {
        self.callBack = completion
        self.parentVC = on
        self.header = header
        display()
    }

    func style() {
        styleFieldHeader(label: titleLabel)
        styleInput(input: input, height: inputHeight)
        styleHollowButton(button: cancelButton)
        styleHollowButton(button: addButton)
        self.view.backgroundColor = UIColor.white
    }

    func display() {
        guard let parent = self.parentVC else {return}
        let whiteScreen = parent.getWhiteScreen()
        let inputContainer = parent.getInputViewContainer()
        whiteScreen.addSubview(inputContainer)
        parent.view.addSubview(whiteScreen)
        parent.addChildViewController(self)
        self.view.frame = inputContainer.frame
        self.view.center.x = parent.view.center.x
        self.view.center.y = parent.view.center.y
        parent.view.addSubview(self.view)
        self.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        self.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        self.didMove(toParentViewController: parent)
        self.input.becomeFirstResponder()
    }

    func remove() {
        guard let parent = self.parentVC else {return}
        parent.removeWhiteScreen()
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

}
