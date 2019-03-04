//
//  FlowConfirmationCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowConfirmationCollectionViewCell: FlowCell {

    // MARK: Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        if let callback = nextClicked {
            return callback()
        }
    }
    
    // MARK: Initialization
    override func whenInitialized() {
        style()
        title.text = "Flow Completed"
    }
    
    // MARK: Style
    func style() {
        styleSubHeader(label: title)
        styleDivider(divider: divider)
        styleFillButton(button: nextButton)
    }
}
