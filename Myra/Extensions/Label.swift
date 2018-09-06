//
//  Label.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-29.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func increaseFontSize(by: CGFloat) {
        let size = self.font.pointSize
        self.font = self.font.withSize(size + by)
    }

    func change(kernValue: Double) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            let textRange = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: kernValue, range: textRange)
            self.attributedText = attributedString
            self.sizeToFit()
        }
    }
}

