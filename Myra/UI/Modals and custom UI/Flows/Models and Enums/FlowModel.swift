//
//  FlowModel.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class FlowModel {
    var flowView: UIView
    var actionName: String
    
    init(flowView: UIView, actionName: String) {
        self.flowView = flowView
        self.actionName = actionName
    }
}
