//
//  Banner.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Banner {
    static let shared = Banner()
    private init() {}
    func showBanner(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let window = UIApplication.shared.keyWindow {
                let banner: SyncBanner = UIView.fromNib()
                window.addSubview(banner)
                banner.show(message: message, x: window.frame.origin.x, y: window.frame.origin.y + 20)
            }
        }
    }
}
