//
//  Logger.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-21.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation

public enum LoggerMode {
    case Off
    case Print
    case Debug
}

class Logger {
    
    public static var mode: LoggerMode = .Print
    
    public static func log(message: String) {
        switch self.mode {
        case .Off:
            return
        case .Print:
            print(message)
        case .Debug:
            show(message: message)
        }
    }
    
    private static func show(message: String) {
        
    }
}
