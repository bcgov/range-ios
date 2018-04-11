//
//  String.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
    var isDouble: Bool {
        return Double(self) != nil
    }
}
