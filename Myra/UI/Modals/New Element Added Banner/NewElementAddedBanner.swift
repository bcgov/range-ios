//
//  NewElementAddedBanner.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-10.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class NewElementAddedBanner {
    static let shared = NewElementAddedBanner()
    private init() {}
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = UIApplication.shared.keyWindow {
                let banner: NewElementBanner = UIView.fromNib()
                window.addSubview(banner)
                let windowWidth = window.frame.width
                let maxY = window.frame.maxY - 8
                banner.show(x: (windowWidth/2), y: maxY)
//                banner.show(x: window.frame.origin.x, y: window.frame.origin.y + 20)
            }
        }
    }
}
