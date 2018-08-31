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
}
