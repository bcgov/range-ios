//
//  CustomSectionHeader.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class CustomSectionHeader: UITableViewHeaderFooterView, Theme {

    var callBack: (()-> Void)?
    var toolTipHelpText = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet weak var actionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!

    func setup(title: String, iconImage: UIImage? = nil, helpDescription: String? = nil, actionButtonName: String? = nil, buttonCallback: @escaping()-> Void) {
        self.callBack = buttonCallback
        self.titleLabel.text = title
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
        titleWidth.constant = title.width(withConstrainedHeight: self.titleLabel.frame.height, font: defaultSectionHeaderFont())
        if let actionButtonTitle = actionButtonName {
            styleFillButton(button: actionButton)
            actionButton.alpha = 1
            actionButton.setTitle(actionButtonTitle, for: .normal)
            actionButtonWidth.constant = actionButtonTitle.width(withConstrainedHeight: actionButton.frame.height, font: Fonts.getPrimary(size: 17)) + 20
        } else {
            actionButton.alpha = 0
        }
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? BaseViewController, let titleText = titleLabel.text else {return}
        parent.showTooltip(on: sender, title: titleText, desc: toolTipHelpText)
    }

    @IBAction func actionButtonAction(_ sender: UIButton) {
        guard let callback = self.callBack else {return}
        return callback()
    }

}
