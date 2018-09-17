//
//  MonitoringAreaBasicInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MonitoringAreaBasicInfoTableViewCell: UITableViewCell, Theme {

    // MARK: Outlets
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!

    @IBOutlet weak var locationHeader: UILabel!
    @IBOutlet weak var locationField: UITextField!

    @IBOutlet weak var rangeLandHeader: UILabel!
    @IBOutlet weak var rangeLandField: UITextField!

    @IBOutlet weak var latitudeHeader: UILabel!
    @IBOutlet weak var latitudeField: UITextField!

    @IBOutlet weak var longitudeHeader: UILabel!
    @IBOutlet weak var longitudeField: UITextField!

    @IBOutlet weak var transectHeader: UILabel!
    @IBOutlet weak var transectField: UITextField!

    @IBOutlet weak var typeHeader: UILabel!
    @IBOutlet weak var typeField: UITextField!

    @IBOutlet weak var rangelandHealthDropDown: UIButton!
    @IBOutlet weak var purposeDropDown: UIButton!


    // MARK: Variables
    var mode: FormMode = .View
    var monitoringArea: MonitoringArea?
    var parentReference: MonitoringAreaViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet actions
    @IBAction func locationFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                ma.location = text
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func latitudeFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                ma.latitude = text
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func longitudeFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                ma.longitude = text
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func transectAzimuthChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                ma.transectAzimuth = text
            }
        } catch _ {
            fatalError()
        }
    }

    @IBAction func purposeAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: Options.shared.getMonitoringAreaPurposeLookup(), onVC: parent, onButton: purposeDropDown) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        ma.purpose = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
    }

    @IBAction func rangelandHealthAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: Options.shared.getRangeLandHealthLookup(), onVC: parent, onButton: rangelandHealthDropDown) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                do {
                    let realm = try Realm()
                    try realm.write {
                        ma.rangelandHealth = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
    }

    // MARK: Setup
    func setup(mode: FormMode, monitoringArea: MonitoringArea, parentReference: MonitoringAreaViewController) {
        self.mode = mode
        self.monitoringArea = monitoringArea
        self.parentReference = parentReference
        style()
        autoFill()
    }

    func autoFill() {
        guard let ma = self.monitoringArea else {return}
        self.locationField.text = ma.location
        self.rangeLandField.text = ma.rangelandHealth
        self.latitudeField.text = ma.latitude
        self.longitudeField.text = ma.longitude
        self.transectField.text = ma.transectAzimuth
        self.typeField.text = ma.purpose
    }

    // MARK: Style
    func style() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: locationField, header: locationHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: rangeLandField, header: rangeLandHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: latitudeField, header: latitudeHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: longitudeField, header: longitudeHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: transectField, header: transectHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: typeField, header: typeHeader, height: fieldHeight)
        case .Edit:
            styleInputField(field: locationField, header: locationHeader, height: fieldHeight)
            styleInputField(field: rangeLandField, header: rangeLandHeader, height: fieldHeight)
            styleInputField(field: latitudeField, header: latitudeHeader, height: fieldHeight)
            styleInputField(field: longitudeField, header: longitudeHeader, height: fieldHeight)
            styleInputField(field: transectField, header: transectHeader, height: fieldHeight)
            styleInputField(field: typeField, header: typeHeader, height: fieldHeight)
        }
    }
    
}
