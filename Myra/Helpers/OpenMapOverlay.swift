//
//  OpenMapOverlay.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import MapKit


// custom map overlays
class OpenMapOverlay: MKTileOverlay {

    // grabs the tile for the current x y z
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let tileUrl = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
        return URL(string: tileUrl)!
    }
}
