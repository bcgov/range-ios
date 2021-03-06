//
//  MapTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapTableViewCell: UITableViewCell {

    let regionRadius: CLLocationDistance = 200

    var locationManager: CLLocationManager = CLLocationManager()

    var currentLocation: CLLocation? {
        didSet {
            currentLat = "\(String(describing: currentLocation?.coordinate.latitude))"
            currentLng = "\(String(describing: currentLocation?.coordinate.longitude))"
        }
    }

    var status: CLAuthorizationStatus?
    var currentLat: String?
    var currentLng: String?

    @IBOutlet weak var mapView: MKMapView!

    var tileRenderer: MKTileOverlayRenderer!

    // types of layers
    var grasses: [MKOverlay] = [MKOverlay]()
    var borders: [MKOverlay] = [MKOverlay]()
    var others: [MKOverlay] = [MKOverlay]()
    var layer1Toggled = false
    var layer2Toggled = false
    var layer3Toggled = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup() {
        initLocation()
        setupTileRenderer()
        loadMap()
        grasses.append(makePolygonOverlay(coordinates: getDummys(), color: .green))
        borders.append(makePolygonOverlay(coordinates: getDummys2(), color: .blue))
        others.append(makePolygonOverlay(coordinates: getDummys3(), color: .yellow))
        let RBCloc = CLLocation(latitude: 48.424402, longitude: -123.365155)
        dropPin(location: RBCloc, name: "COW!")
    }

    @IBAction func layer1Action(_ sender: Any) {
        if layer1Toggled {
            for border in borders {
                mapView.removeOverlay(border)
            }
        } else {
            for border in borders {
                addPolygon(overlay: border)
            }
        }
        layer1Toggled = !layer1Toggled
    }

    @IBAction func layer2Action(_ sender: Any) {
        if layer2Toggled {
            for grass in grasses {
                mapView.removeOverlay(grass)
            }
        } else {
            for grass in grasses {
                addPolygon(overlay: grass)
            }
        }
        layer2Toggled = !layer2Toggled
    }

    @IBAction func layer3Action(_ sender: Any) {
        if layer3Toggled {
            for other in others {
                mapView.removeOverlay(other)
            }
        } else {
            for other in others {
                addPolygon(overlay: other)
            }
        }
        layer3Toggled = !layer3Toggled
    }

    @IBAction func findMeAction(_ sender: Any) {
        focusOnCurrent()
    }
}

// Map
extension MapTableViewCell: MKMapViewDelegate {
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

        return
        /* Test Data */
        /*
        var tocache = [CLLocationCoordinate2D]()
        var one = CLLocationCoordinate2D()
        one.latitude = 48.424251
        one.longitude = -123.365729

        var two = CLLocationCoordinate2D()
        two.latitude = 48.375354
        two.longitude = -123.735889

        var three = CLLocationCoordinate2D()
        three.latitude = 49.149995
        three.longitude = -125.904245

        var four = CLLocationCoordinate2D()
        four.latitude = 49.160894
        four.longitude = -123.938473

        tocache.append(one)
        tocache.append(two)
        tocache.append(three)
        tocache.append(four)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.autoload(coordinates: tocache)
        }
        */
    }

    func autoload(coordinates: [CLLocationCoordinate2D]) {
        var regions: [MKCoordinateRegion] = [MKCoordinateRegion]()
        for element in coordinates {
            var x = 2000000
            var y = 2000000
            while x > 10 && y > 10 {
                let viewRegion = MKCoordinateRegion.init(center: element, latitudinalMeters: CLLocationDistance(x), longitudinalMeters: CLLocationDistance(y))
                regions.append(viewRegion)
                if x > 10000 {
                    if x > 50000 {
                        if x > 1000000 {
                            x -= 20000
                            y -= 20000
                        } else if x > 100000 {
                            x -= 10000
                            y -= 10000
                        } else {
                            x -= 1000
                            y -= 1000
                        }
                    } else {
                        x -= 500
                        y -= 500
                    }
                } else {
                    if x > 5000 {
                        x -= 100
                        y -= 100
                    } else {
                        if x > 1000 {
                            x -= 50
                            y -= 50
                        } else {
                            x -= 10
                            y -= 10
                        }
                    }
                }
            }
        }

        TileMaster.shared.deleteAllStoredTiles()

//        TileMaster.shared.storeTilesAround(x: 41238, y: 90659, z: 18)

        beginCaching(regions: regions) {
            Logger.log(message: "Finished Caching.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                Logger.log(message: "Size of chached map tiles: \(TileMaster.shared.sizeOfStoredTiles())")
            })
        }
    }

    func beginCaching(regions: [MKCoordinateRegion], completion: @escaping ()->Void) {
        var all = regions
        guard let current = all.popLast() else {return completion()}
        mapView.setRegion(current, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.beginCaching(regions: all, completion: completion)
        }
    }

    // Handle rendering of lines and polygons
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        } else if overlay is MKPolygon {
            if let poly = overlay as? Polygon {
                let polygonView = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor = poly.color.withAlphaComponent(0.5)
                polygonView.strokeColor = poly.color
                polygonView.lineWidth = 2
                return polygonView
            }
        }

        return tileRenderer
        //        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapLatitude = mapView.centerCoordinate.latitude
        let mapLongitude = mapView.centerCoordinate.longitude
        currentLocation = CLLocation(latitude: mapLatitude, longitude: mapLongitude)
    }

    func dropPin(location: CLLocation, name: String) {
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        myAnnotation.title = name
        mapView.addAnnotation(myAnnotation)

        if getPins().count > 5 {
            clearPins()
        }
    }

    func clearPins() {
        let pins = getPins()
        mapView.removeAnnotations(pins)
    }

    func getPins() -> [MKAnnotation] {
        return mapView.annotations
    }

    func makePolygonOverlay(coordinates: [CLLocationCoordinate2D], color: UIColor) -> MKOverlay {
        let polygon: Polygon = Polygon(coordinates: coordinates, count: coordinates.count)
        polygon.color = color
        let overlay: MKOverlay = polygon
        return overlay
    }

    func addPolygon(overlay: MKOverlay) {
        mapView.addOverlay(overlay)
    }

    // move map center to current position
    func focusOnCurrent() {
        let loc = locationManager.location?.coordinate
        if loc == nil { return }
        let coordinateRegion = MKCoordinateRegion.init(center: (loc)!,latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // move map center to specified location
    func focusOn(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func getDummys() -> [CLLocationCoordinate2D] {
        let lat1 = 48.423538
        let long1 = -123.362789

        let lat2 = 48.423887
        let long2 = -123.365321

        let lat3 = 48.424706
        let long3 = -123.366533

        let lat4 = 48.425397
        let long4 = -123.364205

        var coordinates: [CLLocationCoordinate2D] = []

        coordinates.append(CLLocationCoordinate2D(latitude: lat1, longitude: long1))
        coordinates.append(CLLocationCoordinate2D(latitude: lat2, longitude: long2))
        coordinates.append(CLLocationCoordinate2D(latitude: lat3, longitude: long3))
        coordinates.append(CLLocationCoordinate2D(latitude: lat4, longitude: long4))

        return coordinates
    }

    func getDummys2() -> [CLLocationCoordinate2D] {

        let lat1 = 48.424893
        let long1 = -123.367888

        let lat2 = 48.425680
        let long2 = -123.367664

        let lat3 = 48.426349
        let long3 = -123.365314

        let lat4 = 48.427004
        let long4 = -123.362696

        let lat5 = 48.425288
        let long5 = -123.359467

        let lat6 = 48.422426
        let long6 = -123.360476

        let lat7 = 48.422597
        let long7 = -123.367224

        var coordinates: [CLLocationCoordinate2D] = []

        coordinates.append(CLLocationCoordinate2D(latitude: lat1, longitude: long1))
        coordinates.append(CLLocationCoordinate2D(latitude: lat2, longitude: long2))
        coordinates.append(CLLocationCoordinate2D(latitude: lat3, longitude: long3))
        coordinates.append(CLLocationCoordinate2D(latitude: lat4, longitude: long4))
        coordinates.append(CLLocationCoordinate2D(latitude: lat5, longitude: long5))
        coordinates.append(CLLocationCoordinate2D(latitude: lat6, longitude: long6))
        coordinates.append(CLLocationCoordinate2D(latitude: lat7, longitude: long7))

        return coordinates
    }

    func getDummys3() -> [CLLocationCoordinate2D] {

        let lat1 =   48.424871
        let long1 = -123.367797

        let lat2 = 48.424732
        let long2 = -123.366591

        let lat3 = 48.424116
        let long3 = -123.366671

        let lat4 = 48.424251
        let long4 = -123.367964

        var coordinates: [CLLocationCoordinate2D] = []

        coordinates.append(CLLocationCoordinate2D(latitude: lat1, longitude: long1))
        coordinates.append(CLLocationCoordinate2D(latitude: lat2, longitude: long2))
        coordinates.append(CLLocationCoordinate2D(latitude: lat3, longitude: long3))
        coordinates.append(CLLocationCoordinate2D(latitude: lat4, longitude: long4))
        return coordinates
    }
}

extension MapTableViewCell {

//        override func url(forTilePath path: MKTileOverlayPath) -> URL {
//            let tileUrl = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
//            return URL(string: tileUrl)!
//        }

    func setupTileRenderer() {
        let overlay = OpenMapOverlay()
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
    }
}

// Location
extension MapTableViewCell: CLLocationManagerDelegate {

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
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.present(alertController, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
