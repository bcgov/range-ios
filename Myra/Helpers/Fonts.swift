//
//  Fonts.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Fonts {

    static func getPrimary(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }

    static func getPrimaryHeavy(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }

    static func getPrimaryLight(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }

    static func getPrimaryMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }


}
