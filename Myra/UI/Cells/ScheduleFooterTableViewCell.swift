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
    var mode: FormMode = .View

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
    func setup(mode: FormMode, schedule: Schedule, agreementID: String) {
        self.mode = mode
        self.schedule = schedule
        self.agreementID = agreementID
        self.textView.text = schedule.notes
        style()
        autofill()
    }

    func autofill() {
        guard let sched = self.schedule else {return}
        let totAUMs = sched.getTotalAUMs()
        self.totalAUMs.text = "\(totAUMs.rounded())"
        if let usage = RUPManager.shared.getUsageFor(year: (sched.year), agreementId: agreementID) {
            let allowed = usage.auth_AUMs
            self.authorizedAUMs.text = "\(allowed)"
            if totAUMs > Double(allowed) {
                totalAUMs.textColor = UIColor.red
            } else {
                totalAUMs.textColor = UIColor.black
            }
        } else {
            self.authorizedAUMs.text = "NA"
        }

        self.textView.text = sched.notes
        if self.mode == .View && self.textView.text == "" {
            self.textView.text = "Description not provided"
        }
    }

    // MARK: Styles
    func style() {
        switch mode {
        case .View:
            styleTextviewInputFieldReadOnly(field: textView, header: scheduleDescriptionHeader)
        case .Edit:
            styleTextviewInputField(field: textView, header: scheduleDescriptionHeader)
        }
        styleDivider(divider: divider)
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
