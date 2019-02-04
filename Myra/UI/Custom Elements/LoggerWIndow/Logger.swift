//
//  Logger.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-21.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

struct LogMessages {
    static let databaseWriteFailure = "Database Write Failed"
    static let databaseDeleteFailure = "Database Delete Failed"
    static let databaseReadFailure = "Database Read Failed"
    static let databseChangeListenerFailure = "Database Change Listener Failed"
}

class Logger {
    private static var modalDuration: Double = 1
    
    static var windowTag = Int.random(in: 200000..<300000)
    static var loggerWindow: LoggerWindow?
    static var logs: [String] = [String]()
    
    public static func log(message: String) {
        logs.append(message)
        if SettingsManager.shared.isInAppLoggerEnabled() {
            show(message: message)
            print("Window enabled - \(message)")
        } else {
            removeWindow()
            print(message)
        }
    }
    
    public static func removeWindow() {
        if let window = self.loggerWindow {
            window.remove()
            self.loggerWindow = nil
        }
        removeLoggerWindowIfExists()
    }
    
    // Displays modal message on screen and shuts dpwn application
    public static func fatalError(message: String) {
        showInModal(title: "Fatal Error", message: message)
        if SettingsManager.shared.shouldQuitAfterFatalError() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        }
    }
    
    private static func showInModal(title: String, message: String) {
        Alert.show(title: title, message: message)
    }
    
    private static func show(message: String) {
        if let window = self.loggerWindow, windowWithTagExists(){
            window.refresh()
            moveWindowToFront()
        } else {
            removeLoggerWindowIfExists()
            let window: LoggerWindow = UIView.fromNib()
            self.loggerWindow = window
            window.initialize()
        }
    }
    
    private static func windowWithTagExists() -> Bool {
        guard let window = UIApplication.shared.keyWindow else {return false}
        if let viewWithTag = window.viewWithTag(windowTag) {
            return true
        }
        return false
    }
    
    private static func moveWindowToFront() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let viewWithTag = window.viewWithTag(windowTag) {
            window.bringSubviewToFront(viewWithTag)
        }
    }
    
    static func removeLoggerWindowIfExists() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let viewWithTag = window.viewWithTag(windowTag) {
            viewWithTag.removeFromSuperview()
            self.loggerWindow = nil
        }
    }
    
    static func initializeIfNeeded() {
        if SettingsManager.shared.isInAppLoggerEnabled(), self.loggerWindow == nil {
            let window: LoggerWindow = UIView.fromNib()
            self.loggerWindow = window
            window.initialize()
        }
    }
}
