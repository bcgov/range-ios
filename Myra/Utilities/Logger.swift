//
//  Logger.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-21.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

public enum LoggerMode {
    case Off
    case Print
    case Debug
}

struct LogMessages {
    static let databaseWriteFailure = "Database Write Failed"
    static let databaseDeleteFailure = "Database Delete Failed"
    static let databaseReadFailure = "Database Read Failed"
    static let databseChangeListenerFailure = "Database Change Listener Failed"
}

class Logger {
    public static var mode: LoggerMode = .Print
    private static var modalDuration: Double = 1
    
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
    
    // Displays modal message on screen and shuts dpwn application
    public static func fatalError(message: String) {
        showInModal(title: "Fatal Error", message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
    
    private static func showInModal(title: String, message: String) {
        
    }
    
    private static func show(message: String) {
        
    }
}
