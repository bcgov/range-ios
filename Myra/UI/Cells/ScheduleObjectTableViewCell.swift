//
//  ScheduleObjectTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleObjectTableViewCell: UITableViewCell {

    var scheduleObject: ScheduleObject?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(scheduleObject: ScheduleObject) {
        self.scheduleObject = scheduleObject
    }
    
}
extension ScheduleObjectTableViewCell {
//    func 
}

