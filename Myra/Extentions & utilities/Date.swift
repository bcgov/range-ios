//
//  Date.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-28.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
extension Date
{
    func string() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd, yyyy"
        return dateFormatter.string(from: self)
    }

}
