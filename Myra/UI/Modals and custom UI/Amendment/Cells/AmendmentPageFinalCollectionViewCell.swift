//
//  AmendmentPageFinalCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AmendmentPageFinalCollectionViewCell: UICollectionViewCell, Theme {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
    }

    func style() {
        styleFillButton(button: continueButton)
        styleSubHeader(label: titleLabel)
    }
}
