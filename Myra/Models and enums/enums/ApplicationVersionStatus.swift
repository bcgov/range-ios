//
//  ApplicationVersionStatus.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-13.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
enum ApplicationVersionStatus {
    case isLatest
    case isOld
    case isNewerThanRemote
    case Unfetched
}
