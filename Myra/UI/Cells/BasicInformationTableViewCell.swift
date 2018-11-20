//
//  BasicInformationTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-24.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class BasicInformationTableViewCell: BaseFormCell {

    // MARK: Constants

    // MARK: Variables

    // MARK: Outlets
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var divider: UIView!

    @IBOutlet weak var agreementInfoHeader: UILabel!
    @IBOutlet weak var contactInfoHeader: UILabel!

    // Contact info
    @IBOutlet weak var districtHeader: UILabel!
    @IBOutlet weak var districtValue: UILabel!

    @IBOutlet weak var zoneHeader: UILabel!
    @IBOutlet weak var zoneValue: UILabel!

    @IBOutlet weak var contactNameHeader: UILabel!
    @IBOutlet weak var contactNameValue: UILabel!

    @IBOutlet weak var contactPhoneHeader: UILabel!
    @IBOutlet weak var contactPhoneValue: UILabel!

    @IBOutlet weak var contactEmailHeader: UILabel!
    @IBOutlet weak var contactEmailValue: UILabel!

    // Agreement info
    @IBOutlet weak var rangeNumberHeader: UILabel!
    @IBOutlet weak var rangeNumberValue: UILabel!

    @IBOutlet weak var agreementTypeHeader: UILabel!
    @IBOutlet weak var agreementTypeValue: UILabel!

    @IBOutlet weak var agreementDateHeader: UILabel!
    @IBOutlet weak var agreementDateValue: UILabel!

    @IBOutlet weak var rangeNameHeader: UILabel!
    @IBOutlet weak var rangeNameValue: UITextField!

    @IBOutlet weak var altBusinessNameHeader: UILabel!
    @IBOutlet weak var altBusinessNameValue: UITextField!
    
    @IBOutlet weak var inputFieldHeight: NSLayoutConstraint!

    // MARK: Outlet actions
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Basic Information", desc: InfoTips.basicInformation)
    }

    @IBAction func rangeNameTooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Range Name", desc: InfoTips.rangeName)
    }

    @IBAction func nameEdited(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.rangeName = self.rangeNameValue.text ?? ""
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func businessNameEdited(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.alternativeName = altBusinessNameValue.text ?? ""
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func beginEditName(_ sender: UITextField) {
        perform(#selector(selectRange), with: sender, afterDelay: 0.01)
    }

    @objc private func selectRange(sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    // MARK: Functions
    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        style()
        autofill()
        self.rangeNameValue.delegate = self
        self.altBusinessNameValue.delegate = self
    }

    func autofill() {
        rangeNumberValue.text = rup.agreementId
        rangeNameValue.text = rup.rangeName
        altBusinessNameValue.text = rup.alternativeName
        agreementTypeValue.text = RUPManager.shared.getType(id: rup.typeId)

        // Zone and District
        if let zone = rup.zones.last {
            self.zoneValue.text = zone.desc
            if let district = zone.districts.last {
                if district.desc == "" {
                    self.districtValue.text = district.code
                } else {
                    self.districtValue.text = district.desc
                }
            }
            contactNameValue.text = zone.contactName
            contactEmailValue.text = zone.contactEmail
            contactPhoneValue.text = zone.contactPhoneNumber

            // TODO: Remove. it's temporary
            if contactPhoneValue.text == "" {
                contactPhoneValue.text = "Not Provided"
            }
        }

        // Agreement date
        if let start = rup.agreementStartDate,  let end = rup.agreementEndDate {
            self.agreementDateValue.text = "\(start.string()) to \(end.string())"
        }
    }

    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        styleSubHeader(label: agreementInfoHeader)
        styleSubHeader(label: contactInfoHeader)
        styleFields()
    }

    func styleFields() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: altBusinessNameValue, header: altBusinessNameHeader, height: inputFieldHeight)
            styleInputFieldReadOnly(field: rangeNameValue, header: rangeNameHeader, height: inputFieldHeight)
        case .Edit:
            styleInputField(field: altBusinessNameValue, header: altBusinessNameHeader, height: inputFieldHeight)
            styleInputField(field: rangeNameValue, header: rangeNameHeader, height: inputFieldHeight)
        }

        styleStaticField(field: districtValue, header: districtHeader)
        styleStaticField(field: zoneValue, header: zoneHeader)
        styleStaticField(field: contactNameValue, header: contactNameHeader)
        styleStaticField(field: contactEmailValue, header: contactEmailHeader)
        styleStaticField(field: contactPhoneValue, header: contactPhoneHeader)

        styleStaticField(field: rangeNumberValue, header: rangeNumberHeader)
        styleStaticField(field: agreementTypeValue, header: agreementTypeHeader)
        styleStaticField(field: agreementDateValue, header: agreementDateHeader)
    }
}
