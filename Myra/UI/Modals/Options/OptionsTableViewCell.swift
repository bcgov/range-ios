//
//  OptionsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var option: Option?

    // MARK: Outlets
    @IBOutlet weak var label: UILabel!

    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Setup
    func setup(option: Option) {
        self.option = option
        self.label.text = option.display
        style()
    }

    // MARK: Style
    func style() {
        menuSectionOn(label: label)
    }
}
