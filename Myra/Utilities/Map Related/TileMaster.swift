//
//  TileMaster.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Alamofire
import Reachability

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class TilePath {
    var root: MKTileOverlayPath
    var subTiles: [TilePath] = [TilePath]()
    init(root: MKTileOverlayPath) {
        self.root = root
    }
}

enum TileProvider {
    case GoogleSatellite
    case GoogleHybrid
    case OpenStreet
}

class TileMaster {

    static let shared = TileMaster()

    let indicatorTag = 7786
    let indicatorLabelTag = 7787

    var minZoom = 18
    var maxZoom = 12
    var allPaths = [MKTileOverlayPath]()
    var tiles = 0

    var isDownloading: Bool = false
    
    // Lets chache these instead of calculating over and over
    var cachedNumberOfStoredTiles: Int = 0
    var cachedSizeOfStoredTiles: Double = 0.0

    // If it keeps failing to download X number of tiles again, don't try again
    var lastFailedCount: Int = 0

    var tempCount = 0
    var tilesOfInterest = [MKTileOverlayPath]()
    
    var tileProvider: TileProvider = .OpenStreet

    private init() {
        Logger.log(message: "Initialized TileMaster. Size of tiles: \(sizeOfStoredTiles())")
    }
    
    func getTileProviderURL(for path: MKTileOverlayPath) -> URL? {
        switch self.tileProvider {
        case .GoogleSatellite:
            return googleSatelliteURL(for: path)
        case .OpenStreet:
            return openSteetMapURL(for: path)
        case .GoogleHybrid:
            return googleHybridURL(for: path)
        }
    }
    
    func googleHybridURL(for path: MKTileOverlayPath) -> URL? {
        let stringURL = "https://mt1.google.com/vt/lyrs=y&x=\(path.x)&y=\(path.y)&z=\(path.z)"
        guard let url = URL(string: stringURL) else {return nil}
        return url
    }
    
    func openSteetMapURL(for path: MKTileOverlayPath) -> URL? {
        let stringURL = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
        guard let url = URL(string: stringURL) else {return nil}
        return url
    }
    
    func googleSatelliteURL(for path: MKTileOverlayPath) -> URL? {
        let stringURL = "http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x=\(path.x)&y=\(path.y)&z=\(path.z)"
        guard let url = URL(string: stringURL) else {return nil}
        return url
    }

    func tileExistsLocally(for tilePath: MKTileOverlayPath) -> Bool {
        let path = localPath(for: fileName(for: tilePath))
        let filePath = path.path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }

    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func localPath(for name: String) -> URL {
        return documentDirectory().appendingPathComponent("\(name)")
    }

    func fileName(for path: MKTileOverlayPath) -> String {
        return "Tile-\(path.z)-\(path.x)-\(path.y).png"
    }

    func sizeOfStoredTiles() -> Double {
        let fileURLs = storedFiles()
        // If number of items hasn't changed retured the last computed size
        if storedFiles().count == self.cachedNumberOfStoredTiles {return self.cachedSizeOfStoredTiles}
        var total: Double = 0
        for item in fileURLs {
            if item.path.contains("Tile") {
                total += sizeOfFileAt(url: item)
            }
        }
        self.cachedNumberOfStoredTiles = storedFiles().count
        self.cachedSizeOfStoredTiles = total
        return total
    }

    func sizeOfFileAt(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            Logger.log(message: "*Error* in TileMaster -> sizeOfFileAt: \(error)")
        }
        return 0.0
    }

    func storedFiles() -> [URL] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            return [URL]()
        }
    }

    func deleteStoreTiles(at urls: [URL]) {
        let fileManager = FileManager.default
        for url in urls where url.path.contains("Tile") {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                return
            }
        }
    }

    func deleteAllStoredTiles() {
        let all = storedFiles()
        deleteStoreTiles(at: all)
        Banner.shared.show(message: "Removed all stored Map tiles")
    }

    func convert(lat: Double, lon: Double, zoom: Int) -> MKTileOverlayPath {
        // Scale factor used to create MKTileOverlayPath object.
        let scaleFactor: CGFloat = 2.0

        // Holders for X Y
        var x: Int = 0
        var y: Int = 0

        // https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
        let n = pow(2, Double(zoom))
        x = Int(n * ((lon + 180) / 360))
        y = Int(n * (1 - (log(tan(lat.degreesToRadians) + (1/cos(lat.degreesToRadians))) / Double.pi)) / 2)

        return MKTileOverlayPath(x: x, y: y, z: zoom, contentScaleFactor: scaleFactor)
    }

    func downloadTilePathsForCenterAt(lat: Double, lon: Double) {
        if let r = Reachability(), r.connection == .none {
            return
        }
        // get the initial tile.
        let initialPath = convert(lat: lat, lon: lon, zoom: maxZoom)
        tilesOfInterest.removeAll()
        tilesOfInterest.append(initialPath)

        findSubtiles(under: initialPath)

        Logger.log(message: "\(tilesOfInterest.count) Tiles of interest")
        let newTiles = findTilesToStoreIn(array: tilesOfInterest)
        Logger.log(message: "\(newTiles.count) are new")

        download(tilePaths: newTiles)
    }

    func findSubtiles(under path: MKTileOverlayPath) {
        if path.z + 1 > minZoom {return}

        let first = MKTileOverlayPath(x: 2 * path.x, y: 2 * path.y, z: path.z + 1, contentScaleFactor: 2.0)

        let second = MKTileOverlayPath(x: 2 * path.x + 1, y: 2 * path.y, z: path.z + 1, contentScaleFactor: 2.0)

        let third = MKTileOverlayPath(x: 2 * path.x, y: 2 * path.y + 1, z: path.z + 1, contentScaleFactor: 2.0)

        let forth = MKTileOverlayPath(x: 2 * path.x + 1, y: 2 * path.y + 1, z: path.z + 1, contentScaleFactor: 2.0)

        tilesOfInterest.append(first)
        tilesOfInterest.append(second)
        tilesOfInterest.append(third)
        tilesOfInterest.append(forth)

        findSubtiles(under: first)
        findSubtiles(under: second)
        findSubtiles(under: third)
        findSubtiles(under: forth)
    }

    func getPercentage(of value: Int, in total: Int) -> Double {
        return (Double((value * 100)) / Double(total)).roundToDecimal(1)
    }

    func download(tilePaths: [MKTileOverlayPath]) {
        if let r = Reachability(), r.connection == .none {
            return
        }

        if tilePaths.isEmpty {
            // Nothing to Download
            return
        }

        if self.isDownloading {
            return
        }

        self.isDownloading = true

        var failedTiles = [MKTileOverlayPath]()

        Banner.shared.show(message: "Downloading \(tilePaths.count) Map tiles")
        addStatusIndicator()
        var count = tilePaths.count {
            didSet {
                self.updateStatusValue(to: getPercentage(of: count, in: tilePaths.count))
            }
        }

        let queue = DispatchQueue(label: "tileQues", qos: .background, attributes: .concurrent)
        queue.async {
            let dispatchGroup = DispatchGroup()

            for i in 0...tilePaths.count - 1 {

                dispatchGroup.enter()
                let current = tilePaths[i]
                if self.tileExistsLocally(for: current) {
                    count -= 1
                    dispatchGroup.leave()
                } else {
                    Thread.sleep(until: Date(timeIntervalSinceNow: 0.0001))
                    self.downloadTile(for: current) { (success) in
                        count -= 1
                        if !success {
                            failedTiles.append(current)
                            Logger.log(message: "Failed to download a tile. total Failuers: \(failedTiles.count)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.downloadCompleted(failed: failedTiles)
            }
        }
    }

    func downloadTile(for path: MKTileOverlayPath, then: @escaping (_ success: Bool)-> Void) {
        if let r = Reachability(), r.connection == .none {
            return then(false)
        }
        let queue = DispatchQueue(label: "tileQue", qos: .background, attributes: .concurrent)

        guard let url = getTileProviderURL(for: path) else {
            return then(false)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 3
        Alamofire.request(request).responseData(queue: queue) { (response) in
            switch response.result {
            case .success(_):
                if let data = response.data {
                    do {
                        try data.write(to: self.localPath(for: self.fileName(for: path)))
                        return then(true)
                    } catch {
                        return then(false)
                    }
                } else {
                    return then(false)
                }
            case .failure(_):
                return then(false)
            }
        }
    }

    func downloadCompleted(failed: [MKTileOverlayPath]) {

        tilesOfInterest.removeAll()
        removeStatusIndicator()

        self.isDownloading = false
        if self.lastFailedCount == failed.count {
            if lastFailedCount == 0 {
                print("No tiles failed to download.")
                Banner.shared.show(message: "Finished download map data. total size: \(sizeOfStoredTiles().roundToDecimal(2))MB")
                return
            } else {
                Banner.shared.show(message: "Will not try to download failed tiles in this session.")
                lastFailedCount = 0
                return
            }
        } else {
            Banner.shared.show(message: "\(failed.count) tiles failed to download")
            lastFailedCount = failed.count

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.download(tilePaths: failed)
            }
        }
    }

    func findTilesToStoreIn(array: [MKTileOverlayPath]) -> [MKTileOverlayPath] {
        var newTiles: [MKTileOverlayPath] = [MKTileOverlayPath]()
        for element in array {
            if !tileExistsLocally(for: element) {
                newTiles.append(element)
            }
        }
        return newTiles
    }

    // MARK: Status
    func addStatusIndicator() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else {return}
            let width: CGFloat = 100
            let height: CGFloat = 100
            let frame = CGRect(x: window.frame.maxX, y: window.frame.maxY, width: width, height: height)
            let view = UIView(frame: frame)
            let label = UILabel(frame: frame)

            view.tag = self.indicatorTag
            label.tag = self.indicatorLabelTag

            window.addSubview(view)
            window.addSubview(label)

            label.textAlignment = .center

            self.addAnchors(to: view, in: window, width: width, height: height)
            self.addAnchors(to: label, in: window, width: width, height: height)

            label.font = Fonts.getPrimary(size: 15)
            view.backgroundColor = Colors.primary
            label.textColor = Colors.primary
            view.layer.cornerRadius = height/2
            view.alpha = 0.1
        }
    }

    func addAnchors(to view: UIView, in window: UIWindow, width: CGFloat, height: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: height),
            view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            view.leftAnchor.constraint(equalTo: window.leftAnchor)
            ])
    }

    func updateStatusValue(to percent: Double) {
        DispatchQueue.main.async {
            Feedback.removeButton()
            guard let window = UIApplication.shared.keyWindow else {return}
            if let label = window.viewWithTag(self.indicatorLabelTag) as? UILabel {
                let remaining = 100 - percent
                label.text = "\(remaining.roundToDecimal(1))%"
            }
        }
    }

    func removeStatusIndicator() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else {return}
            if let label = window.viewWithTag(self.indicatorLabelTag) {
                label.removeFromSuperview()
            }

            if let view = window.viewWithTag(self.indicatorTag) {
                view.removeFromSuperview()
            }
            Feedback.initializeButton()
        }
    }
}
