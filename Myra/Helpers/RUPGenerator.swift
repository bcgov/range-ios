//
//  RUPGenerator.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class RUPGenerator {
    static let shared = RUPGenerator()

    private init() {}

    func getSamples(number: Int) -> [RUP] {
        var rups = [RUP]()
        for i in 0...number {
            rups.append(RUP(id: "RUP\(i)", info: "Info for rup #\(i)"))
        }
        return rups
    }
}
