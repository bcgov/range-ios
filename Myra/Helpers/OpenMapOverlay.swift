//
//  OpenMapOverlay.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Reachability


// custom map overlays
class OpenMapOverlay: MKTileOverlay {

    // grabs the tile for the current x y z
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        if let r = Reachability(), r.connection == .none {
            return super.url(forTilePath: path)
        }

        if TileMaster.shared.tileExistsLocally(for: path) {
            // return local URL
            return TileMaster.shared.localPath(for: TileMaster.shared.fileName(for: path))
        } else {
            // Otherwise download and save
            TileMaster.shared.downloadTile(for: path) { (success) in
            }
            // If you're downloading and saving, then you could also just pass the url to renderer
            let tileUrl = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
            return URL(string: tileUrl)!
        }
    }
}
