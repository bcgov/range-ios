//
//  SettingButtonTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class SettingButtonTableViewCell: UITableViewCell, Theme {
    
    // MARK: Variables
    var callBack: (()-> Void)?
    
    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    
    // MARK: Class func
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
           style()
        }
    }
    // MARK: Outlet Actons
    @IBAction func buttonAction(_ sender: UIButton) {
        if let callBack = self.callBack {
            return callBack()
        }
    }
    
    // MARK: Setup
    func setup(titleText: String, callBack: @escaping () -> Void) {
        self.callBack = callBack
        self.button.setTitle(titleText, for: .normal)
        style()
    }
    
    // MARK: Style
    func style() {
        if let buttonLabel = button.titleLabel {
            styleSubHeader(label: buttonLabel)
        }
    }
}
