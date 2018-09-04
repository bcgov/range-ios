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
    @IBOutlet weak var textView: UITextView!
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
    // MARK: Setup
    func setup(mode: FormMode, schedule: Schedule, agreementID: String) {
        self.mode = mode
        self.schedule = schedule
        self.agreementID = agreementID
        self.textView.text = schedule.notes
        style()
        autofill()
    }

    // MARK: Autofill
    func autofill() {
        guard let schedule = self.schedule else {return}
        self.textView.text = schedule.notes
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
    }
}

// MARK: Notes
extension ScheduleFooterTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let schedule = self.schedule else {return}
        do {
            let realm = try Realm()
            try realm.write {
                schedule.notes = textView.text
            }
        } catch _ {
            fatalError()
        }
    }
}
