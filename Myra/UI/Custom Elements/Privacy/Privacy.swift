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
        setPIAText()
    }
    
    func setPIAText() {
        let text = "Personal information is collected under the legal authority of section 26 (c) and 27 (1)(a)(i) of the Freedom of Information and Protection of Privacy Act (the Act). The collection, use, and disclosure of personal information is subject to the provisions of the Act. The personal information collected will be used to process your submission(s). It may also be shared when strictly necessary with partner agencies that are also subject to the provisions of the Act. The personal information supplied in the submission may be used for referrals, consultation, or notifications as required. Staff may use your personal information to contact you regarding your submission or for survey purposes.\n\nFor more information regarding the collection, use, and/or disclosure of your personal information, please contact MyRangeBC Administrator at:\n\nEmail: myrangebc@gov.bc.ca\nTelephone: 250 371-3827\n\nMailing Address:\nMinistry of Forests, Lands, Natural Resource Operations and Rural Development\nRange Branch - Kamloops\nAttn: MyRangeBC\n441 Columbia Street\nKamloops, BC\nV2C 2T3"
        self.textView.text = text
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
