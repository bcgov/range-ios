//
//  Alert.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    static func show(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        let view: AlertView = UIView.fromNib()
        view.initialize(mode: .YesNo, title: title, message: message, rightButtonCallback: {
            return yes()
        }) {
            return no()
        }
    }

    static func show(title: String, message: String) {
        let view: AlertView = UIView.fromNib()
        view.initialize(mode: .Message, title: title, message: message, rightButtonCallback: {}) {}
    }
}
