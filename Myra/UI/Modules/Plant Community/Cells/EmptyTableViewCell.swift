//
//  EmptyTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class EmptyTableViewCell: BaseTableViewCell {

    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(placeHolder: String, height: CGFloat) {
        self.label.text = placeHolder
        self.height.constant = height
        styleSubHeader(label: label)
    }
    
}
