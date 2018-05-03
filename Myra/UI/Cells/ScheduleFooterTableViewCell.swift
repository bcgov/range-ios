//
//  ScheduleFooterTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleFooterTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var schedule: Schedule?
    var agreementID: String = " "

    // MARK: Outlets
    @IBOutlet weak var totalBox: UIView!
    @IBOutlet weak var authorizedBox: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var authorizedAUMs: UILabel!
    @IBOutlet weak var totalAUMs: UILabel!
    @IBOutlet weak var scheduleDescriptionHeader: UILabel!
    @IBOutlet weak var divider: UIView!

    // MARK: Cell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
        autofill()
        textView.delegate = self
    }

    // MARK: Functions
    func setup(schedule: Schedule, agreementID: String) {
        self.schedule = schedule
        self.agreementID = agreementID
        self.textView.text = schedule.notes
        autofill()
    }

    func autofill() {
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

        self.textView.text = schedule?.notes
    }

    // MARK: Styles
    func style() {
        styleDivider(divider: divider)
        styleInputField(field: textView, header: scheduleDescriptionHeader)
        styleFieldHeader(label: authorizedAUMs)
        styleFieldHeader(label: totalAUMs)
        styleBox(layer: totalBox.layer)
        styleBox(layer: authorizedBox.layer)
    }

    func styleBox(layer: CALayer) {
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
    }
}

// MARK: Notes
extension ScheduleFooterTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        do {
            let realm = try Realm()
            try realm.write {
                self.schedule?.notes = textView.text
            }
        } catch _ {
            fatalError()
        }
    }
}
