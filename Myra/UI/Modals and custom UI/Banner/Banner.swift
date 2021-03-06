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
    let displayDuration: TimeInterval = 5
    var messages: [String] = [String]()
    var showing = false

    private init() {}

    func show(message: String) {
        if message.isEmpty {return}
        /* Avoid repeating the same messsage */
        if !messages.contains(message) {
            messages.append(message)
        }
        if !showing {
            recursiveShow()
        }
    }

    func recursiveShow() {
        guard let message = self.messages.first else {
            self.showing = false
            return
        }
        self.messages.remove(at: 0)
        self.showing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let window = UIApplication.shared.keyWindow {
                let banner: SyncBanner = UIView.fromNib()
                window.addSubview(banner)
                banner.show(message: message, x: window.frame.origin.x, y: window.frame.origin.y + 20,duration: self.displayDuration, then: {
                    /* Avoid repeating the same messsage */
                    if self.messages.contains(message) {
                        for i in 0...self.messages.count - 1  where self.messages[i] == message {
                            self.messages.remove(at: i)
                        }
                    }
                    self.recursiveShow()
                })
            } else {
                self.showing = false
                return
            }
        }
    }
    
    func bannerTextFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 14)
    }
}
