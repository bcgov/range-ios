//
//  Option.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class Option {
    var type: OptionType
    var display: String

    init(type: OptionType, display: String) {
        self.type = type
        self.display = display
    }
}
