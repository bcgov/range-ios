//
//  BasicInfoSectionTwoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BasicInfoSectionTwoTableViewCell: UITableViewCell {

    var rup: RUP?
    var mode: FormMode = .Create

    @IBOutlet weak var rupzone: UITextField!
    @IBOutlet weak var alternativeBusinesName: UITextField!
    @IBOutlet weak var districtResponsible: UITextField!
    @IBOutlet weak var agreementType: UITextField!
    @IBOutlet weak var rangeName: UITextField!
    @IBOutlet weak var planStart: UITextField!
    @IBOutlet weak var planEnd: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func planStartAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        DatePickerController.present(on: parent, completion: { (date) in
            guard let date = date else { return }
            self.planStart.text = date.string()
            self.rup?.planStartDate = date
            if self.planEnd.text != "" {
                let endDate = DateManager.from(string: self.planEnd.text!)
                if endDate < date {
                    self.planEnd.text = DateManager.toString(date: (self.rup?.planStartDate)!)
                    self.rup?.planEndDate = self.rup?.planStartDate
                }
            }
        })

    }
    
    @IBAction func planEndAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController

        if planStart.text != "" {
            let startDate = DateManager.from(string: planStart.text!)
            DatePickerController.present(on: parent, minimum: startDate, completion: { (date) in
                guard let date = date else { return }
                self.planEnd.text = date.string()
                self.rup?.planEndDate = date
            })
        } else {
            DatePickerController.present(on: parent, completion: { (date) in
                guard let date = date else { return }
                self.planEnd.text = date.string()
                self.rup?.planEndDate = date
            })
        }
    }
    
    func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
        autofill()
    }

    func autofill() {
        if rup == nil { return }
        if mode == .View || mode == .Edit {
            self.rupzone.text = rup?.basicInformation?.RUPzone
            self.alternativeBusinesName.text = rup?.basicInformation?.alternativeBusinessName
            self.districtResponsible.text = rup?.basicInformation?.district
            self.agreementType.text = rup?.basicInformation?.agreementType
            self.rangeName.text = rup?.basicInformation?.rangeName
            self.planStart.text = rup?.basicInformation?.planStart.string()
            self.planEnd.text = rup?.basicInformation?.planEnd.string()

            if let zone = rup?.zone {
                self.rupzone.text = zone.code
            }
//            if let 

            self.alternativeBusinesName.text = rup?.basicInformation?.alternativeBusinessName
            self.districtResponsible.text = rup?.basicInformation?.district

            self.agreementType.text = rup?.basicInformation?.agreementType

            self.rangeName.text = rup?.basicInformation?.rangeName
            self.planStart.text = rup?.basicInformation?.planStart.string()
            self.planEnd.text = rup?.basicInformation?.planEnd.string()
        } else {
            print(rup)
            if let zone = rup?.zone {
                self.rupzone.text = zone.code
            }
            if let rangeName = rup?.rangeName {
                self.rangeName.text = rangeName
            }
            if let district = rup?.zone?.district {
               districtResponsible.text = district.code
            }
            if let start = rup?.planStartDate {
                self.planStart.text = DateManager.toString(date: start)
            }

            if let end = rup?.planEndDate {
                self.planEnd.text = DateManager.toString(date: end)
            }
        }
    }

    func setFieldMode() {
        switch mode {
        case .Create:
            rupzone.isUserInteractionEnabled = true
            alternativeBusinesName.isUserInteractionEnabled = true
            districtResponsible.isUserInteractionEnabled = true
            agreementType.isUserInteractionEnabled = true
            rangeName.isUserInteractionEnabled = true
            planStart.isUserInteractionEnabled = true
            planEnd.isUserInteractionEnabled = true
        case .Edit:
            rupzone.isUserInteractionEnabled = true
            alternativeBusinesName.isUserInteractionEnabled = true
            districtResponsible.isUserInteractionEnabled = true
            agreementType.isUserInteractionEnabled = true
            rangeName.isUserInteractionEnabled = true
            planStart.isUserInteractionEnabled = true
            planEnd.isUserInteractionEnabled = true
        case .View:
            rupzone.isUserInteractionEnabled = false
            alternativeBusinesName.isUserInteractionEnabled = false
            districtResponsible.isUserInteractionEnabled = false
            agreementType.isUserInteractionEnabled = false
            rangeName.isUserInteractionEnabled = false
            planStart.isUserInteractionEnabled = false
            planEnd.isUserInteractionEnabled = false
        }
    }
    
}
