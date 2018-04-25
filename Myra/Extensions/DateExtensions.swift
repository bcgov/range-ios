//
//  DateExtensions.swift
//  Myra
//
//  Created by Jason Leach on 2018-04-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

extension Date {

    func yearOfDate() -> Int? {
        let components = Calendar.current.dateComponents([.year], from: self)

        return components.year
    }
}
