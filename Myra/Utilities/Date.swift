//
//  Date.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-28.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension Date {
    func string() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self)
    }

    
    public func startOf() -> Date?{
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }

}
