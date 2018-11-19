//
//  Feedback.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class Feedback {
    static func show(in vc: UIViewController) {
        let view: FeedbackView = UIView.fromNib()
        view.present(in: vc)
    }

    static func send(feedback: FeedbackElement, completion: @escaping (_ success: Bool)->Void) {
        guard let endpoint = URL(string: Constants.API.feedbackPath, relativeTo: Constants.API.baseURL!) else {
            return completion(false)
        }
        API.post(endpoint: endpoint, params: feedback.toDictionary()) { (response) in
            return completion(true)
        }
    }
}
