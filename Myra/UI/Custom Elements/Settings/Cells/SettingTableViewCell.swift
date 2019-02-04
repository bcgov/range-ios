//
//  SettingTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-08.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var toggleCallback: ((_ isOn: Bool) -> Void )?

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    // MARK: Class func
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            style()
        }
    }
    
    // MARK: Actions
    @IBAction func toggleAction(_ sender: UISwitch) {
        guard let callback = toggleCallback else {return}
        return callback(sender.isOn)
    }

    // MARK: Setup
    func setup(titleText: String, isOn: Bool, toggleCallback: @escaping (_ isOn: Bool)-> Void) {
        self.toggleCallback = toggleCallback
        // Autofill
        self.titleLabel.text = titleText
        self.toggle.isOn = isOn
        style()
    }

    // MARK: Style
    func style() {
        toggle.onTintColor = Colors.switchOn
        styleSubHeader(label: titleLabel)
    }
    
}
