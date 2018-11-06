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
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var titleWidth: NSLayoutConstraint!

    var toolTipHelpText = ""

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setup(title: String, iconImage: UIImage? = nil, helpDescription: String? = nil) {
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

        if let help = helpDescription {
            tooltipButton.isHidden = false
            self.toolTipHelpText = help

        } else {
            tooltipButton.isHidden = true
        }
        titleWidth.constant = title.width(withConstrainedHeight: 60, font: defaultSectionHeaderFont())
    }


    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? BaseViewController, let titleText = titleLabel.text else {return}
        parent.showTooltip(on: sender, title: titleText, desc: toolTipHelpText)
    }



    

}
