//
//  AppDelegate.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realmNotificationToken: NotificationToken?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS) && DEBUG
        // so we can find our Documents
        print("documents = \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
        #endif
        // Remove dummy plan if exists
        DummyData.removeDummyPlanAndAgreement()
        // My way of making sure the settingsManager singleton exists before referenced elsewhere
        print("Current Environment is \(SettingsManager.shared.getCurrentEnvironment())")
        // Keyboard settings
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        // Fabric
        Fabric.with([Crashlytics.self])
        // Begin Autosync change listener
        AutoSync.shared.beginListener()
        
       

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AutoSync.shared.endListener()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print(SettingsManager.shared.getCurrentEnvironment())
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
         AutoSync.shared.beginListener()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

