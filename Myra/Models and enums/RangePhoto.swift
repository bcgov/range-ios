//
//  RangePhoto.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-28.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Extended
import CoreLocation

class RangePhoto: Object, MyraObject {

    @objc dynamic var remoteId: Int = -1

    @objc dynamic var timeStamp: Date?
    @objc dynamic var content: String = ""
    @objc dynamic var ran: String = ""

    // Location
    @objc dynamic var lat: Double = -1
    @objc dynamic var long: Double = -1
    
    // Azimuth
    @objc dynamic var magneticHeading: Double = -1
    @objc dynamic var trueHeading: Double = -1
    @objc dynamic var headingAccuracy: Double = -1
    
//    @objc dynamic var metadata: [String : Any]?

    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    func toDictionary() -> [String : Any] {
        return [String : Any]()
    }

    func getImage(thumbnail: Bool? = false) -> UIImage? {
        var path = getFullImagePath()
        if let thumbnail = thumbnail, thumbnail {
            path = getThumbnailPath()
        }
        return UIImage(contentsOfFile: path.path)
//        var data: Data? = nil
//        do {
//            try data = Data(contentsOf: path)
//            return data
//        } catch {
//            return data
//        }
    }

    func set(content: String, ran: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.content = content
                self.ran = ran
            }
        } catch {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

  /*  func save(from photo: Photo) {
        guard let image = photo.image else {return}
//        self.metadata = photo.metadata

        lat = photo.latitude
        long = photo.longitude

        magneticHeading = photo.magneticHeading
        trueHeading = photo.trueHeading
        headingAccuracy = photo.headingAccuracy

        timeStamp = Date()

        if save(image: image) {
            _ = save(image: image, thumbnail: true)
        }

        RealmRequests.saveObject(object: self)
    }*/

    func getThumbnailPath() -> URL {
        let fileName = "\(localId)*Thumbnail.jpeg"
        return getDocumentsDirectory().appendingPathComponent("\(fileName)")
    }

    func getFullImagePath() -> URL {
        let fileName = "\(localId)*Full.jpeg"
        return getDocumentsDirectory().appendingPathComponent("\(fileName)")
    }

    func save(image: UIImage, thumbnail: Bool? = false) -> Bool {
        var compressionQuality: CGFloat = 1
        var imageToStore = image
        var fileURL: URL = getFullImagePath()
        if let thumbnail = thumbnail, thumbnail {
            fileURL = getThumbnailPath()
            compressionQuality = 0.3
            // if we cant reduce size, we will just stora at original size.
            if let thumbSize = resizeImage(image: imageToStore) {
                imageToStore = thumbSize
            }
        }
        guard let data: Data = imageToStore.jpegData(compressionQuality: compressionQuality) else {
            return false
        }
        do {
            try data.write(to: fileURL)
        } catch {
            return false
        }
        return true
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func resizeImage(image: UIImage) -> UIImage? {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 120.0
        let maxWidth: Float = 120.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.25
        //50 percent compression

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {return nil}
        guard let imageData = img.jpegData(compressionQuality: CGFloat(compressionQuality)) else {
            return nil
        }
        UIGraphicsEndImageContext()
        return UIImage(data: imageData)
    }
}
