//
//  MapViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import MapKit

import UIKit
import MapKit
import CoreLocation
import Extended
extension MKMapView {
    public func dropPin(at coordinates: CLLocationCoordinate2D, name: String) {
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = coordinates
        myAnnotation.title = name
        self.addAnnotation(myAnnotation)
    }
}
class MapViewController: UIViewController, Theme {

//    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!

    let regionRadius: CLLocationDistance = 200

    let stationRadius: Double = 50

    var locationManager: CLLocationManager = CLLocationManager()
    var status: CLAuthorizationStatus?
    var currentLocation: CLLocation?

    var tileRenderer: MKTileOverlayRenderer!

    var photos: [RangePhoto] = [RangePhoto]()

    var selectedIndex: Int = -1

    @IBAction func close(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setRangePhotos()
    }

    func setup() {
        initLocation()
//        initCollectionView()
        loadMap()
    }

    func setRangePhotos() {
        if let stored = RealmRequests.getObject(RangePhoto.self) {
//            RealmRequests.deleteObject(stored.last!)
//            for item in stored {
//                RealmRequests.deleteObject(item)
//            }
            self.photos = stored
            dropPins()
        }
    }

    func dropPins() {
        if photos.isEmpty {return}
        for i in 0...photos.count - 1 {

            if photos[i].lat != -1 && photos[i].long != -1 {
                let coordinate = CLLocationCoordinate2D(latitude: photos[i].lat, longitude: photos[i].long)
                mapView.dropPin(at: coordinate, name: "\(i)")
            }
        }
    }

//    func select(index: Int) {
//        var prevIndexPath: IndexPath?
//        if selectedIndex > 0 && selectedIndex < stations.count {
//            prevIndexPath = IndexPath(row: selectedIndex, section: 0)
//        }
//        let indexPath: IndexPath = IndexPath(row: index, section: 0)
//        let station = stations[index]
//        if let location = station.coordinates {
//            mapView.focusOn(location: location, radius: stationRadius)
//        }
//        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        selectedIndex = index
//        var toReload: [IndexPath] = [IndexPath]()
//        toReload.append(indexPath)
//        if let prev = prevIndexPath {
//            toReload.append(prev)
//        }
//        self.collectionView.reloadItems(at: toReload)
//    }
}

// Location
extension MapViewController: CLLocationManagerDelegate {
    func initLocation() {
        locationManager.delegate = self

        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()

        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
                                                message: "We need permission",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        present(alertController, animated: true, completion: nil)

    }
}

extension MapViewController: MKMapViewDelegate{
    func loadMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true

        //Zoom to user location
        var noLocation = CLLocationCoordinate2D()
        noLocation.latitude = 48.424251
        noLocation.longitude = -123.365729
        let viewRegion = MKCoordinateRegion.init(center: noLocation, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: true)

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let indexString = annotation.title, let unwrapped = indexString, let index = Int(unwrapped) else {return nil}
        let nib = UINib(nibName: "Pin", bundle: nil)
        if let pin = nib.instantiate(withOwner: nil, options: nil)[0] as? Pin {
            pin.set(photo: photos[index])
            return pin
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pin = view as? Pin, let photo = pin.photo {
            for i in 0...photos.count - 1 where photos[i].content == photo.content {
                //                let indexPath = IndexPath(row: i, section: 0)
                //                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//                select(index: i)
                return
            }
        }
    }

    //    func clearPins() {
    //        let pins = getPins()
    //        mapView.removeAnnotations(pins)
    //    }
    //
    //    func getPins() -> [MKAnnotation] {
    //        return mapView.annotations
    //    }

    // move map center to current position
    func focusOnCurrent() {
        let loc = locationManager.location?.coordinate
        if loc == nil { return }
        let coordinateRegion = MKCoordinateRegion.init(center: (loc)!,latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

//extension MapViewController


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

/*
// MARK: Extension CollectionView
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func initCollectionView() {
        registerCell(name: "StationCollectionViewCell")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = cellSize()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func cellSize(middle: Bool? = false) -> CGSize {
        var w = (self.collectionView.frame.width / 2.5)
        var h = w + 20
        if let isMiddle = middle, isMiddle {
            w = w + 20
            h = h + 20
        }
        return CGSize(width: w, height: h)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var isCenter = false
        if let centerIndex = collectionView.centerCellIndexPath {
            isCenter = centerIndex == indexPath
        }
        return cellSize(middle: isCenter)
    }

    func registerCell(name: String) {
        collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }

    func getStationCollectionViewCellCell(indexPath: IndexPath) -> StationCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "StationCollectionViewCell", for: indexPath) as! StationCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getStationCollectionViewCellCell(indexPath: indexPath)
        cell.setup(with: stations[indexPath.row], currentLocation: currentLocation, selected: (indexPath.row == selectedIndex))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(index: indexPath.row)
        //        if let location = stations[indexPath.row].coordinates {
        //            mapView.focusOn(location: location, radius: stationRadius)
        //        }
    }
}
 */

