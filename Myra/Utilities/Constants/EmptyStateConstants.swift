//
//  EmptyStateConstants.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-03-25.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
struct EmptyStateConstants {
    struct Home {
        struct FilterAll {
            static let title: String = "Looking a little barren around here?"
            static let message: String = "You have not created any RUPs yet in MyRange BC. Use the Create New RUP button to select a RAN and create a new digital RUP."
            static let icon: UIImage = UIImage(named: "Seedling") ?? UIImage()
        }
        
        struct Drafts {
            static let title: String = "Looking a little barren around here?"
            static let message: String = "There are no RUP’s matching this status."
            static let icon: UIImage = UIImage(named: "Seedling") ?? UIImage()
        }
        
        struct Pending {
            static let title: String = "Looking a little barren around here?"
            static let message: String = "There are no RUP’s matching this status."
            static let icon: UIImage = UIImage(named: "Seedling") ?? UIImage()
        }
        
        struct Completed {
            static let title: String = "Looking a little barren around here?"
            static let message: String = "There are no RUP’s matching this status."
            static let icon: UIImage = UIImage(named: "Seedling") ?? UIImage()
        }
    }
}
