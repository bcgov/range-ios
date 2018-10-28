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

class MonitoringAreaBasicInfoTableViewCell: UITableViewCell, Theme {

    static let cellHeight: CGFloat = (320 + 16)

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
    @IBOutlet weak var getMyCoordinatesButton: UIButton!

    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var divider: UIView!

    // MARK: Variables
    var mode: FormMode = .View
    var monitoringArea: MonitoringArea?
    var parentReference: PlantCommunityViewController?

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
            Loading.shared.begin()
            initLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                if self.currentLocation == nil {
                    Banner.shared.show(message: "Could not get your location")
                    self.currentNumberOfAdjustments = 0
                }

                if self.currentNumberOfAdjustments >= self.maxNumberOfAdjustments {
                     self.locationManager.stopUpdatingLocation()
                    self.currentNumberOfAdjustments = 0
                }

                Loading.shared.end()
            }
        } else {
            autofillLatLong()
        }
    }

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

    @IBAction func optionsAction(_ sender: Any) {

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
            fatalError()
        }
        self.latitudeField.text = monitoringArea.latitude
        self.longitudeField.text = monitoringArea.longitude

        if currentNumberOfAdjustments < minNumberOfAdjustments {
            Loading.shared.end()
        }

        // Do not confinue of max number of adjustments has been reached
        if currentNumberOfAdjustments > maxNumberOfAdjustments {
            self.locationManager.stopUpdatingLocation()
            self.currentNumberOfAdjustments = 0
            Loading.shared.end()
        }
    }

    // MARK: Setup
    func setup(mode: FormMode, monitoringArea: MonitoringArea, parentReference: PlantCommunityViewController) {
        self.mode = mode
        self.monitoringArea = monitoringArea
        self.parentReference = parentReference
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
            getMyCoordinatesButton.isHidden = true
        case .Edit:
            styleInputField(field: locationField, header: locationHeader, height: fieldHeight)
            styleInputField(field: rangeLandField, header: rangeLandHeader, height: fieldHeight)
            styleInputField(field: latitudeField, header: latitudeHeader, height: fieldHeight)
            styleInputField(field: longitudeField, header: longitudeHeader, height: fieldHeight)
            styleInputField(field: transectField, header: transectHeader, height: fieldHeight)
            styleInputField(field: typeField, header: typeHeader, height: fieldHeight)
            getMyCoordinatesButton.isHidden = false
            styleHollowButton(button: getMyCoordinatesButton)
        }
//        styleDivider(divider: divider)
        styleSubHeader(label: nameLabel)
        styleSubHeader(label: nameHeader)
        styleContainer(view: container)
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
