//
//  TooltipViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class TooltipViewController: UIViewController, Theme {

    var titleString: String = ""
    var descriptionString: String = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var icon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        autofill()
    }

    func setup(title: String, desc: String) {
        titleString = title
        descriptionString = desc
    }

    func autofill() {
        if titleLabel != nil {
            self.titleLabel.text = titleString
            self.descriptionTextView.text = descriptionString
        }
    }

    func style() {
        descriptionTextView.isEditable = false
        styleToolTipTitle(label: titleLabel)
        styleToolTipDescription(textView: descriptionTextView)
        self.view.backgroundColor = Colors.active.blue
    }

}
