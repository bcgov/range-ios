//
//  StringExtension.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-28.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func width(for button: UIButton) -> CGFloat? {
        guard let titleLabel = button.titleLabel else {return nil}
        return self.width(withConstrainedHeight: button.frame.height, font: titleLabel.font)
    }
    
    func height(for button: UIButton)-> CGFloat? {
        guard let titleLabel = button.titleLabel else {return nil}
        return self.height(withConstrainedWidth: button.frame.width, font: titleLabel.font)
    }
    
    func width(for label: UILabel) -> CGFloat {
        return self.width(withConstrainedHeight: label.frame.height, font: label.font)
    }
    
    func height(for label: UILabel, subtractWidth: CGFloat = 0)-> CGFloat {
        return self.height(withConstrainedWidth: label.frame.width - subtractWidth, font: label.font)
    }
    
    
}
