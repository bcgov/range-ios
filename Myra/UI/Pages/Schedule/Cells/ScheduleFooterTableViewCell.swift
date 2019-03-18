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

class ScheduleFooterTableViewCell: BaseTableViewCell {

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
        if self.textView.text.isEmpty {
            switch mode {
            case .View:
                self.textView.text = "Description not provided"
            case .Edit:
                addPlaceHolder()
            }
        }
    }

    // MARK: Styles
    func style() {
        switch mode {
        case .View:
            styleTextviewInputFieldReadOnly(field: textView, header: scheduleDescriptionHeader)
        case .Edit:
            styleTextviewInputField(field: textView, header: scheduleDescriptionHeader)
            if textView.text == PlaceHolders.Schedule.description {
                textView.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
            }
        }
        styleDivider(divider: divider)
    }
}

// MARK: Notes
extension ScheduleFooterTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == PlaceHolders.Schedule.description {
            removePlaceHolder()
        }
    }
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let schedule = self.schedule else {return}
        if textView.text != PlaceHolders.Schedule.description {
            do {
                let realm = try Realm()
                try realm.write {
                    schedule.notes = textView.text
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }
        if textView.text == "" {
            addPlaceHolder()
        }
    }

    func addPlaceHolder() {
        textView.text = PlaceHolders.Schedule.description
        textView.textColor = defaultInputFieldTextColor().withAlphaComponent(0.5)
    }

    func removePlaceHolder() {
        textView.text = ""
        textView.textColor = defaultInputFieldTextColor().withAlphaComponent(1)
    }
}
