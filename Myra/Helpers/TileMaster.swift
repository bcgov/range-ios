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

class TileMaster {

    static let shared = TileMaster()

    var minZoom = 18
    var maxZoom = 12
    var allPaths = [MKTileOverlayPath]()
    var tiles = 0

    var tempCount = 0
    var tilesOfInterest = [MKTileOverlayPath]()

    private init() {
        print("Initialized TileMaster. Size of tiles: \(sizeOfStoredTiles())")
    }

    func openSteetMapURL(for path: MKTileOverlayPath) -> URL? {
        let stringURL = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
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
        var total: Double = 0
        for item in fileURLs {
            if item.path.contains("Tile") {
                total += sizeOfFileAt(url: item)
            }
        }
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
            print("Error: \(error)")
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
        for url in urls {
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
            print("You're offline. cannot download tiles")
            return
        }
        // get the initial tile.
        let initialPath = convert(lat: lat, lon: lon, zoom: maxZoom)
        tilesOfInterest.removeAll()
        tilesOfInterest.append(initialPath)

        findSubtiles(under: initialPath)

        print("\(tilesOfInterest.count) tiles to download")

        downloadTilesOfInterest()
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

    func download(tilePaths: [MKTileOverlayPath]) {
        if let r = Reachability(), r.connection == .none {
            print("You're offline. cannot download tiles")
            return
        }
        let queue = DispatchQueue(label: "tileQues", qos: .background, attributes: .concurrent)
        var count = tilePaths.count {
            didSet {
                print("\(count) tiles remain for download")
                if count < 1 {
                    self.downloadCompleted()
                }
            }
        }

        Banner.shared.show(message: "Downloading \(tilePaths.count) tiles")

        queue.async {
            for i in 0...tilePaths.count - 1 {
                Thread.sleep(until: Date(timeIntervalSinceNow: 0.0001))
                let current = tilePaths[i]

                if self.tileExistsLocally(for: current) {
                    count -= 1
                } else {
                    self.downloadTile(for: current) { (success) in
                        count -= 1
                        if !success {
                            print("Failed to download a tile")
                        }
                    }
                }
            }
        }

    }

    func downloadTile(for path: MKTileOverlayPath, then: @escaping (_ success: Bool)-> Void) {
        if let r = Reachability(), r.connection == .none {
            print("You're offline. cannot download tile")
            return then(false)
        }
        let queue = DispatchQueue(label: "tileQue", qos: .background, attributes: .concurrent)
        guard let url = openSteetMapURL(for: path) else {return then(false)}
        Alamofire.request(url, method: .get).responseData(queue: queue) { (response) in
            if let data = response.data {
                do {
                    try data.write(to: self.localPath(for: self.fileName(for: path)))
                    return then(true)
                } catch {
                    return then(false)
                }
            }
            return then(false)
        }
    }

    func downloadTilesOfInterest() {
        download(tilePaths: tilesOfInterest)
    }

    func downloadCompleted() {
        Banner.shared.show(message: "Finished download map data. total size: \(sizeOfStoredTiles())")
    }

}
