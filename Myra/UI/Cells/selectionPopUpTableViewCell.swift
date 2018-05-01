//
//  selectionPopUpTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class selectionPopUpTableViewCell: UITableViewCell {

    var object: SelectionPopUpObject?

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        if object != nil {
            label.text = object?.display
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(object: SelectionPopUpObject, bg: UIColor) {
        self.object = object
        if label != nil {
            label.text = object.display
        }
        self.label.font = Fonts.getPrimary(size: 17)
        self.backgroundColor = bg
    }
    
}
