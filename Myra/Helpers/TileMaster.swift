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

class ImageLoader {

    private static let cache = NSCache<NSString, NSData>()

    class func image(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {

            if let data = self.cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
                return
            }

            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }

            self.cache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
        }
    }

}

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
        sizeOfStoredTiles()
    }

//    func saveTile(for path: MKTileOverlayPath) {
//        let imageName = getFileName(for: path)
//        let urlString = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
//        let filePath = getPath(for: imageName)
//        guard let url = URL(string: urlString) else {return}
//        downloadImage(at: url) { (image) in
//            guard let img = image, let data: Data = img.pngData() else {return}
//            do {
//                try data.write(to: filePath)
//                print("Saved Tile")
//                print("***")
//            } catch {
//                return
//            }
//        }
//    }

    func openSteetMapURL(for path: MKTileOverlayPath) -> URL? {
        let stringURL = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
        guard let url = URL(string: stringURL) else {return nil}
        return url
    }

    func tileExistsLocally(for tilePath: MKTileOverlayPath) -> Bool {
        let path = localPath(for: fileName(for: tilePath))
        let filePath = path.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
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

//    func downloadImage(at url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
//        ImageLoader.image(for: url) { (response) in
//            return completion(response)
//        }
//    }

    func sizeOfStoredTiles() -> Double {
        let fileURLs = storedFiles()
        var total: Double = 0
        for item in fileURLs {
            if item.path.contains("Tile") {
                total += sizeOfFileAt(url: item)
            }
        }
        print("\(fileURLs.count) Tiles stored: \(total)MB")
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
//
//    func getPathsForTilesAround(x: Int, y: Int, z: Int) -> [MKTileOverlayPath] {
//        tiles = 0
//        var paths: [MKTileOverlayPath] = [MKTileOverlayPath]()
//        for i in 1...100 {
//            for j in 1...100 {
//                paths.append(MKTileOverlayPath(x: x + i, y: y + j, z: z, contentScaleFactor: 2.0))
//                paths.append(MKTileOverlayPath(x: x - i, y: y - j, z: z, contentScaleFactor: 2.0))
//            }
//        }
//        return paths
//    }
//
//    func storeTilesAround(x: Int, y: Int, z: Int, then: @escaping ()->Void) {
//        let paths = getPathsForTilesAround(x: x, y: y, z: z)
//        let group = DispatchGroup()
//        print("Downloading \(paths.count)")
//        for element in paths {
//            group.enter()
//            self.saveTile(for: element)
//        }
//
//        group.notify(queue: .main) {
//            return then()
//        }
//    }

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
        // get the initial tile.
        let initialPath = convert(lat: lat, lon: lon, zoom: maxZoom)
        tilesOfInterest.removeAll()
        tilesOfInterest.append(initialPath)

        findSubtiles(under: initialPath)

        print("\(tilesOfInterest.count) tiles to download")

        downloadTilesOfInterest()
    }

    func download(tilePaths: [MKTileOverlayPath]) {
        let queue = DispatchQueue(label: "tileQue", qos: .background, attributes: .concurrent)
        var count = tilePaths.count {
            didSet {
                print("\(count) tiles remain for download")
                if count < 1 {
                    self.downloadCompleted()
                }
            }
        }

        for i in 0...tilePaths.count - 1 {
            let current = tilePaths[i]

            if tileExistsLocally(for: current) {
                count -= 1
//                print("Tile Exists")
            } else {
                downloadTile(for: current) { (success) in
                    count -= 1
                    if !success {
                        print("Failed to download a tile")
                    }
                }
            }
        }
    }

    func downloadTile(for path: MKTileOverlayPath, then: @escaping (_ success: Bool)-> Void) {
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
        }
    }

    func downloadTilesOfInterest() {
        download(tilePaths: tilesOfInterest)
//        tempCount = tilesOfInterest.count
//
//        for i in 0...tilesOfInterest.count - 1 where !tileExistsLocally(for: tilesOfInterest[i]){
//            downloadTileAt(path: tilesOfInterest[i])
//        }
    }



//    func downloadTileAt(path: MKTileOverlayPath) {
//        let queue = DispatchQueue(label: "tileQue", qos: .background, attributes: .concurrent)
//        if let url = getURL(for: path) {
//            Alamofire.request(url, method: .get).responseData(queue: queue) { (response) in
//                if let data = response.data {
//                    do {
//                        try data.write(to: self.getPath(for: self.getFileName(for: path)))
//                        self.tempCount -= 1
//                        print("\(self.tempCount) tiles remain")
//                        if self.tempCount < 1 {
//                            self.downloadCompleted()
//                        }
//                    } catch {
//                        return
//                    }
//                }
//            }
//        }
//    }

    func downloadCompleted() {
        print("WOOOOOOOOOOHOOOOO")
        sizeOfStoredTiles()
    }

    /*
    func downloadSubtilesFor(path: MKTileOverlayPath) {
        if path.z + 1 > minZoom {return}
        let first = MKTileOverlayPath(x: 2 * path.x, y: 2 * path.y, z: path.z + 1, contentScaleFactor: 2.0)

        let second = MKTileOverlayPath(x: 2 * path.x + 1, y: 2 * path.y, z: path.z + 1, contentScaleFactor: 2.0)

        let third = MKTileOverlayPath(x: 2 * path.x, y: 2 * path.y + 1, z: path.z + 1, contentScaleFactor: 2.0)

        let forth = MKTileOverlayPath(x: 2 * path.x + 1, y: 2 * path.y + 1, z: path.z + 1, contentScaleFactor: 2.0)

        saveTile(for: first)
        saveTile(for: second)
        saveTile(for: third)
        saveTile(for: forth)

        downloadSubtilesFor(path: first)
        downloadSubtilesFor(path: second)
        downloadSubtilesFor(path: third)
        downloadSubtilesFor(path: forth)
    }
    */

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

//    func findSubtilesFor(tilePath: TilePath) -> [TilePath] {
////        if tilePath.root.z + 1 > minZoom {return }
//        var subtiles: [TilePath] = [TilePath]()
//
//        let first = MKTileOverlayPath(x: 2 * tilePath.root.x, y: 2 * tilePath.root.y, z: tilePath.root.z + 1, contentScaleFactor: 2.0)
//
//        let second = MKTileOverlayPath(x: 2 * tilePath.root.x + 1, y: 2 * tilePath.root.y, z: tilePath.root.z + 1, contentScaleFactor: 2.0)
//
//        let third = MKTileOverlayPath(x: 2 * tilePath.root.x, y: 2 * tilePath.root.y + 1, z: tilePath.root.z + 1, contentScaleFactor: 2.0)
//
//        let forth = MKTileOverlayPath(x: 2 * tilePath.root.x + 1, y: 2 * tilePath.root.y + 1, z: tilePath.root.z + 1, contentScaleFactor: 2.0)
//
//        subtiles.append(TilePath(root: first))
//        subtiles.append(TilePath(root: second))
//        subtiles.append(TilePath(root: third))
//        subtiles.append(TilePath(root: forth))
//
//        tempCount += 4
//        for subtile in subtiles {
//            subtile.subTiles = findSubtilesFor(tilePath: subtile)
//        }
//
//        return subtiles
//    }


}
