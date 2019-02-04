//
//  LoggerWindowTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-01.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class LoggerWindowTableViewCell: UITableViewCell {

    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(withMessage message: String) {
        self.messageLabel.text = message
        style()
        cellHeight.constant = message.height(withConstrainedWidth: messageLabel.frame.width, font: messageLabel.font)
    }
    
    func style() {
        self.messageLabel.textColor = UIColor(hex: "6fdc93")
    }
}
