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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setup(title: String) {
        self.titleLabel.text = title
        styleSubHeader(label: titleLabel)
    }

}
