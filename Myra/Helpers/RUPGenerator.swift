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
            let temp = RUP(id: "RUP\(i)", info: "Info for rup #\(i)")
            temp.primaryAgreementHolderLastName = randomString(length: 5)
            temp.primaryAgreementHolderFirstName = randomString(length: 5)
            rups.append(temp)
        }
        return rups
    }

    func randomString(length: Int) -> String {
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
}
