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

    func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String, caseInsensitive: Bool = true) -> String {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }

        if let range = self.range(of: searchString, options: options, range: nil, locale: nil) {

            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }

    func convertFromCamelCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }

    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

}
