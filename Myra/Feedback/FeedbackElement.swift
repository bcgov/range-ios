//
//  FeedbackElement.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
                  
class FeedbackElement {
    var feedback: String
    var section: String
    var anonymous: Bool

    init(feedback: String, section: String, anonymous: Bool) {
        self.feedback = feedback
        self.section = section
        self.anonymous = anonymous
    }

    func toDictionary() -> [String: Any]{
        return [
            "anonymous": anonymous,
            "section": section,
            "feedback": feedback
        ]
    }
}
