//
//  TourTip.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-18.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import MaterialShowcase

import UIKit

class TourTip {
    var title: String = ""
    var desc: String = ""
    var target: UIView
    var style: MaterialShowcase.BackgroundTypeStyle?
    var rippleBG: UIColor?
    var activeRipple: Bool?

    init(title: String, desc: String, target: UIView, style: MaterialShowcase.BackgroundTypeStyle? = .circle, rippleBG: UIColor? = Colors.active.lightBlue) {
        self.title = title
        self.desc = desc
        self.target = target
        self.style = style
        self.rippleBG = rippleBG
        self.activeRipple = self.style != .full
    }
}
