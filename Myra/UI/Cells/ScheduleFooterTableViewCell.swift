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
    var agreementID: String = " "

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

    func setup(schedule: Schedule, agreementID: String) {
        self.schedule = schedule
        self.agreementID = agreementID
        setValues()
    }

    func setValues() {
        if self.totalAUMs == nil || self.schedule == nil {return}
        let totAUMs = RUPManager.shared.getTotalAUMsFor(schedule: self.schedule!)
        self.totalAUMs.text = "\(totAUMs.rounded())"
        let usage = RUPManager.shared.getUsageFor(year: (schedule?.year)!, agreementId: agreementID)
        let allowed = usage?.auth_AUMs ?? 0
        self.authorizedAUMs.text = "\(allowed)"

        // could also use
        // RUPManager.shared.isScheduleValid(schedule: schedule, agreementID: agreementID)

        if totAUMs > Double(allowed) {
            totalAUMs.textColor = UIColor.red
        } else {
            totalAUMs.textColor = UIColor.black
        }
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

extension ScheduleFooterTableViewCell {

}
