//
//  ScheduleFooterTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleFooterTableViewCell: UITableViewCell {

    var schedule: Schedule?

    @IBOutlet weak var totalBox: UIView!
    @IBOutlet weak var authorizedBox: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var authorizedAUMs: UILabel!
    @IBOutlet weak var totalAUMs: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
        setValues()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(schedule: Schedule) {
        self.schedule = schedule
        setValues()
    }

    func setValues() {
         if self.totalAUMs == nil || self.schedule == nil {return}
        self.totalAUMs.text = "\(RUPManager.shared.getTotalAUMsFor(schedule: self.schedule!))"
    }

    func style() {
        styleBox(layer: totalBox.layer)
        styleBox(layer: textView.layer)
        styleBox(layer: authorizedBox.layer)
    }

    func styleBox(layer: CALayer) {
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
    }
    
}
