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
    var value: String = ""
    var taken: [String] = [String]()
    var object: TestEntry?
    var callBack: ((_ add: Bool, _ value: String) -> Void )?
    var acceptedPopupInput: AcceptedPopupInput = .String

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
            return c(false, "")
        }
    }

    @IBAction func addAction(_ sender: UIButton) {
        if let c = self.callBack {
            return c(true, value)
        }
    }

    @IBAction func inputChanged(_ sender: UITextField) {
        if let text = sender.text {
            // has value
            if text == "" {
                titleLabel.text = "Please enter a value"
                titleLabel.textColor = UIColor.red
                return
            } else {
                // value is not duplicate
                if taken.contains(text) {
                    titleLabel.text = "Duplicate value"
                    titleLabel.textColor = UIColor.red
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
                            titleLabel.text = "Invalid value"
                            titleLabel.textColor = UIColor.red
                        }
                    case .Integer:
                        if text.isInt {
                            self.value = text
                        } else {
                            titleLabel.text = "Invalid value"
                            titleLabel.textColor = UIColor.red
                        }
                    case .Year:
                        if text.isInt {
                            let year = Int(text) ?? 0
                            if (year > 2000) && (year < 2100) {
                                self.value = text
                            } else {
                                titleLabel.text = "Invalid Year"
                                titleLabel.textColor = UIColor.red
                            }
                        } else {
                            titleLabel.text = "Invalid value"
                            titleLabel.textColor = UIColor.red
                        }
                    }
                }
            }
        }
    }

    func setup(completion: @escaping (_ add: Bool, _ value: String) -> Void) {
        self.callBack = completion
    }

    func style() {
        styleFieldHeader(label: titleLabel)
        styleInput(input: input, height: inputHeight)
        styleHollowButton(button: cancelButton)
        styleHollowButton(button: addButton)
        self.view.backgroundColor = UIColor.white
    }


}
