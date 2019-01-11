//
//  SettingInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class SettingInfoTableViewCell: UITableViewCell, Theme {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    // MARK: Setup
    func setup(titleText: String, infoText: String) {
        self.titleLabel.text = titleText
        self.infoLabel.text = infoText
        style()
    }
    
    // MARK: Style
    func style() {
        styleSubHeader(label: titleLabel)
        styleSubHeader(label: infoLabel)
        infoLabel.textColor = Colors.technical.bodyText
    }
}
