//
//  SelectionPopUpObject.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class SelectionPopUpObject {
    var display: String = ""
    var value: String = ""

    init(display: String, value: String? = nil) {
        if let v = value {
            self.value = v
        } else {
            self.value = display
        }
        self.display = display
    }
}

