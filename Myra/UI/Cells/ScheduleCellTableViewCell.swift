//
//  ScheduleCellTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleCellTableViewCell: UITableViewCell {
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    var schedule: Schedule?
    var rup: RUP?

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(schedule: Schedule) {
        self.schedule = schedule
    }
    
    @IBAction func optionsAction(_ sender: Any) {
        print("show option")
    }

    func style() {
        let layer = cellContainer
        layer?.layer.cornerRadius = 3
        layer?.layer.borderWidth = 1
        layer?.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1).cgColor
    }
}
