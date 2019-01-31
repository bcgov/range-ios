//
//  Privacy.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-31.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Privacy: CustomModal {
    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Outlet Actions
    @IBAction func buttonAction(_ sender: UIButton) {
        remove()
    }
    
    // MARK: Entry Point
    func initialize() {
        setSmartSizingWith(percentHorizontalPadding: 35, percentVerticalPadding: 35)
        style()
        present()
    }
    
    // Mark: Style
    func style() {
        styleModalBox()
        divider.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        title.font = Fonts.getPrimaryBold(size: 22)
        title.textColor = Colors.active.blue
        textView.font = Fonts.getPrimary(size: 17)
        textView.textColor = Colors.bodyText
        styleFillButton(button: button)
    }
}
