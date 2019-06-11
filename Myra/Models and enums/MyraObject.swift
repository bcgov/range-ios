//
//  MyraObject.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

protocol MyraObject {
    var localId: String { get set }
    var remoteId: Int { get set }

    func toDictionary() -> [String: Any]
}
