//
//  TourTip.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-18.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class TourTip {
    var title: String = ""
    var desc: String = ""
    var target: UIView

    init(title: String, desc: String, target: UIView) {
        self.title = title
        self.desc = desc
        self.target = target
    }
}
