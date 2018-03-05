//
//  PolyBoarder.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import MapKit
import UIKit

// technically a model, but is kind of an extention to enable custom colors
// for separate polygons
class Polygon: MKPolygon {
    var color: UIColor = UIColor.black
}
