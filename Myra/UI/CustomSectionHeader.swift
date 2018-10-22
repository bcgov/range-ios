//
//  CustomSectionHeader.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class CustomSectionHeader: UITableViewHeaderFooterView, Theme {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var divider: UIView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setup(title: String, iconImage: UIImage? = nil) {
        self.titleLabel.text = title
//        styleSubHeader(label: titleLabel)
        styleHeader(label: titleLabel, divider: divider)
        titleLabel.increaseFontSize(by: -12)
        divider.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        if let iconImage = iconImage {
            self.icon.image = iconImage
            self.icon.alpha = 1
        } else {
            self.icon.alpha = 0
        }
    }

    

}
