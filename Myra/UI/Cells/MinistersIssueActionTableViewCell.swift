//
//  MinistersIssueActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-29.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MinistersIssueActionTableViewCell: BaseFormCell {

    var action: MinisterIssueAction?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(action: MinisterIssueAction,mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        self.action = action
    }
    
}
