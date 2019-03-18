//
//  MonitoringAreaBasicInfoTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import CoreLocation
import Realm
import RealmSwift

class MonitoringAreaBasicInfoTableViewCell: BaseTableViewCell {

    static let cellHeight: CGFloat = (320 + 16 + 8)

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

    @IBOutlet weak var typeHeader: UILabel!
    @IBOutlet weak var typeField: UITextField!

    @IBOutlet weak var rangelandHealthDropDown: UIButton!
    @IBOutlet weak var purposeDropDown: UIButton!
    @IBOutlet weak var getMyCoordinatesButton: UIButton!

    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var divider: UIView!

    @IBOutlet weak var purposeButton: UIButton!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!

    // MARK: Variables
    var mode: FormMode = .View
    var monitoringArea: MonitoringArea?
    var parentReference: PlantCommunityViewController?
    var parentCellReference: PlantCommunityMonitoringAreasTableViewCell?

    // location
    let maxNumberOfAdjustments = 4
    let minNumberOfAdjustments = 2
    var currentNumberOfAdjustments = 0
    var locationManager: CLLocationManager = CLLocationManager()
    var status: CLAuthorizationStatus?
    
    var currentLocation: CLLocation? {
        didSet{
            autofillLatLong()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet actions
    @IBAction func getMyCoordinatesAction(_ sender: UIButton) {
        if currentLocation == nil, CLLocationManager.locationServicesEnabled() {
            Loading.shared.start()
            initLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // If Plant community page is still presnted
                if UIView.viewController(ofType: PlantCommunityViewController.self) != nil {
                    if self.currentLocation == nil {
                        Banner.shared.show(message: "Could not get your location")
                        self.currentNumberOfAdjustments = 0
                    }
                    
                    if self.currentNumberOfAdjustments >= self.maxNumberOfAdjustments {
                        self.locationManager.stopUpdatingLocation()
                        self.currentNumberOfAdjustments = 0
                    }
                    
                    Loading.shared.stop()
                }
                Loading.shared.stop()
            }
        } else {
            autofillLatLong()
        }
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentReference else {return}
        parent.showTooltip(on: sender, title: "Monitoring Area Purpose", desc: InfoTips.monitoringAreaPurpose)
    }

    @IBAction func locationFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                ma.location = text
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    @IBAction func latitudeFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        if let doubleLat = Double(text) {
            sender.textColor = defaultInputFieldTextColor()
            do {
                let realm = try Realm()
                try realm.write {
                    ma.latitude = text
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        } else {
            sender.textColor = Colors.accent.red
            do {
                let realm = try Realm()
                try realm.write {
                    ma.longitude = ""
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }
    }

    @IBAction func LongFieldChanged(_ sender: UITextField) {
        guard let ma = self.monitoringArea, let text = sender.text else {return}
        if let doubleLong = Double(text) {
            sender.textColor = defaultInputFieldTextColor()
            do {
                let realm = try Realm()
                try realm.write {
                    ma.longitude = text
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        } else {
            sender.textColor = Colors.accent.red
            do {
                let realm = try Realm()
                try realm.write {
                    ma.longitude = ""
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }
    }

    @IBAction func purposeAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        let purposesArray = ma.purpose.split{$0 == ","}.map(String.init)
        var selectedObjects = [SelectionPopUpObject]()
        var otherText = ""
        for element in purposesArray {
            if let pType = Reference.shared.getMonitoringAreaPurposeType(named: element) {
                selectedObjects.append(SelectionPopUpObject(display: pType.name))
                if pType.name.lowercased() == "other" {
                    otherText = element
                }
            }
        }

        lookup.otherText = otherText

        lookup.setupLive(onVC: parent, onButton: sender, selected: selectedObjects, objects: Options.shared.getMonitoringAreaPurposeLookup()) { (selection) in
            if let selectedOptions = selection {
                var selectedOptionsString = ""
                for selectedOption in selectedOptions {
                    if selectedOptionsString.isEmpty {
                        selectedOptionsString = "\(selectedOption.display)"
                    } else {
                        selectedOptionsString = "\(selectedOptionsString),\(selectedOption.display)"
                    }
                }
                do {
                    let realm = try Realm()
                    try realm.write {
                        ma.purpose = selectedOptionsString
                    }
                    self.autoFill()
                } catch _ {
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
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
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
                }
            }
        }
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let p = self.parentReference, let parentCell = self.parentCellReference else {return}
        let vm = ViewManager()
        let optionsVC = vm.options

        // create options for module, in this case copy and delete
        let options: [Option] = [Option(type: .Copy, display: "Copy"),Option(type: .Delete, display: "Delete")]

        // set up and handle call back
        optionsVC.setup(options: options, onVC: p, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                p.showAlert(title: "Are you sure?", description: "Remove this monitoring area?", yesButtonTapped: {
                    RUPManager.shared.deleteMonitoringArea(monitoringArea: ma)
                    parentCell.updateTableHeight()
                }, noButtonTapped: {})

            case .Copy:
                self.duplicate()
            }
        }
    }
    // MARK: Utility
    func duplicate() {
        guard let ma = self.monitoringArea, let parentCell = self.parentCellReference else {return}
        parentCell.addNewMonitoringArea(copyFrom: ma)
    }

    // MARK: Setup
    func setup(mode: FormMode, monitoringArea: MonitoringArea, parentReference: PlantCommunityViewController, parentCellReference: PlantCommunityMonitoringAreasTableViewCell) {
        self.mode = mode
        self.monitoringArea = monitoringArea
        self.parentReference = parentReference
        self.parentCellReference = parentCellReference
        style()
        autoFill()
    }

    func autoFill() {
        guard let ma = self.monitoringArea else {return}
        self.nameLabel.text = ma.name
        self.locationField.text = ma.location
        self.rangeLandField.text = ma.rangelandHealth
        self.latitudeField.text = ma.latitude
        self.longitudeField.text = ma.longitude

        // Doing this to add spaces between commas.
        // We don't store with the spaces because we need to break the names
        // in order to find and send the ids to backend. white spaces would make it tricky
        var newString = ""
        let purposesArray = ma.purpose.split{$0 == ","}.map(String.init)
        for element in purposesArray {
            if newString.isEmpty {
                newString = element
            } else {
                newString = "\(newString), \(element)"
            }
        }

        // change the last comma to "and" for better grammar.
        self.typeField.text = newString.replacingLastOccurrenceOfString(", ", with: " and ")
    }

    func autofillLatLong() {
        // Do not continue if in view mode
        if self.mode == .View {return}

        guard let location = currentLocation, let monitoringArea = self.monitoringArea else {return}

        let lat = "\(location.coordinate.latitude)"
        let long = "\(location.coordinate.longitude)"
        self.currentNumberOfAdjustments += 1

        do {
            let realm = try Realm()
            try realm.write {
                monitoringArea.latitude = lat
                monitoringArea.longitude = long
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }

        self.latitudeField.text = monitoringArea.latitude
        self.longitudeField.text = monitoringArea.longitude

        if currentNumberOfAdjustments < minNumberOfAdjustments {
            Loading.shared.stop()
        }

        // Do not confinue of max number of adjustments has been reached
        if currentNumberOfAdjustments > maxNumberOfAdjustments {
            self.locationManager.stopUpdatingLocation()
            self.currentNumberOfAdjustments = 0
            Loading.shared.stop()
        }
    }

    // MARK: Style
    func style() {
        switch mode {
        case .View:
            styleInputFieldReadOnly(field: locationField, header: locationHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: rangeLandField, header: rangeLandHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: latitudeField, header: latitudeHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: longitudeField, header: longitudeHeader, height: fieldHeight)
            styleInputFieldReadOnly(field: typeField, header: typeHeader, height: fieldHeight)
            getMyCoordinatesButton.isHidden = true
            healthButton.isUserInteractionEnabled = false
            purposeButton.isUserInteractionEnabled = false
            optionsButton.alpha = 0
            optionsButton.isUserInteractionEnabled = false
            purposeDropDown.alpha = 0
            rangelandHealthDropDown.alpha = 0
            
        case .Edit:
            styleInputField(field: locationField, header: locationHeader, height: fieldHeight)
            styleInputField(field: rangeLandField, header: rangeLandHeader, height: fieldHeight)
            styleInputField(field: latitudeField, header: latitudeHeader, height: fieldHeight)
            styleInputField(field: longitudeField, header: longitudeHeader, height: fieldHeight)
            styleInputField(field: typeField, header: typeHeader, height: fieldHeight)
            getMyCoordinatesButton.isHidden = false
            styleHollowButton(button: getMyCoordinatesButton)
        }
//        styleDivider(divider: divider)
        styleSubHeader(label: nameLabel)
        styleSubHeader(label: nameHeader)
        styleContainer(view: container)
        self.layoutIfNeeded()
    }
}

// Location
extension MonitoringAreaBasicInfoTableViewCell: CLLocationManagerDelegate {

    func initLocation() {
        locationManager.delegate = self

        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()

        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
    }

    // getLatestLocation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
        }
    }

    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }

    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "In order to autofill your coordinates, we need access to your location",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        if let parent = self.parentReference {
            parent.present(alertController, animated: true, completion: nil)
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
