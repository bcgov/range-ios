//
//  EmptyPastureTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class EmptyStateTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var iconHolder: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    func setup(icon: UIImage? = nil, title: String? = nil, message: String, fixedHeight: CGFloat? = nil) {
        style()
        self.label.text = message
        
        var guestimatedHeight: CGFloat = 200
        guestimatedHeight += message.height(for: label)
        
        if let title = title {
            titleLabel.isHidden = false
            titleLabel.text = title
            guestimatedHeight += title.height(for: titleLabel)
        } else {
            titleLabel.isHidden = true
        }
        
        if let iconImage = icon {
            iconHolder.isHidden = false
            iconHolder.image = iconImage
            guestimatedHeight += 50
        } else {
            iconHolder.isHidden = true
        }
        
        if let useFixedHeight = fixedHeight {
            containerHeight.constant = useFixedHeight
        } else {
            containerHeight.constant = guestimatedHeight
        }
    }

    func style() {
        styleContainer(view: container)
        styleTitle()
        styleMessage()
    }
    
    func styleTitle() {
        titleLabel.font = Fonts.getPrimaryBold(size: 22)
        titleLabel.textColor = UIColor.gray
    }
    
    func styleMessage() {
        label.font = Fonts.getPrimary(size: 17)
        label.textColor = UIColor.gray
    }
}
