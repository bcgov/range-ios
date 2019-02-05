//
//  Settings.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class SettingsModel: Object {
    
    @objc dynamic var realmID: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "realmID"
    }
    
    @objc dynamic var autoSyncEndbaled: Bool = true
    @objc dynamic var cacheMapEndbaled: Bool = true
    
    // Dev tools
    @objc dynamic var devEnvironmentEnabled: Bool = true
    @objc dynamic var quitAfterFatalError: Bool = true
    @objc dynamic var inAppLoggerActive: Bool = false
    
    // UX
    @objc dynamic var animationDuration: Double = 0.5
    @objc dynamic var shortAnimationDuration: Double = 0.3
    
    @objc dynamic var userFirstName: String = ""
    @objc dynamic var userLastName: String = ""
    
    func clone() -> SettingsModel {
        let new = SettingsModel()
        new.autoSyncEndbaled = self.autoSyncEndbaled
        new.cacheMapEndbaled = self.cacheMapEndbaled
        new.devEnvironmentEnabled = self.devEnvironmentEnabled
        new.inAppLoggerActive = self.inAppLoggerActive
        new.quitAfterFatalError = self.quitAfterFatalError
        new.animationDuration = self.animationDuration
        new.shortAnimationDuration = self.shortAnimationDuration
        // dont clone user name
        return new
    }
    
    // MARK: Setters
    func setAutoSync(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                autoSyncEndbaled = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setUser(firstName:String, lastName: String) {
        do {
            let realm = try Realm()
            try realm.write {
                userFirstName = firstName
                userLastName = lastName
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setCacheMap(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                cacheMapEndbaled = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setDevEnvironment(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                devEnvironmentEnabled = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setQuitAfterFatalError(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                quitAfterFatalError = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setInAppLogger(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                inAppLoggerActive = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setAnimationDuration(to value: Double) {
        do {
            let realm = try Realm()
            try realm.write {
                animationDuration = value
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setShortAnimationDuration(to value: Double) {
        do {
            let realm = try Realm()
            try realm.write {
                shortAnimationDuration = value
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
}

enum EndpointEnvironment {
    case Dev
    case Prod
}

class SettingsManager {
    
    // MARK: Variables
    private var quitAfterFatalError: Bool = true
    private let defaultShortAnimationDuration: Double = 0.3
    private let defaultAnimationDuration: Double = 0.5
    
    static let shared = SettingsManager()

    private init() {
        guard let currentModel = getModel() else {
            let newModel = SettingsModel()
            RealmRequests.saveObject(object: newModel)
            return
        }
        self.quitAfterFatalError = currentModel.quitAfterFatalError
    }
    
    // MARK: Internal Functions
    private func getModel()-> SettingsModel? {
        if let query = RealmRequests.getObject(SettingsModel.self), let model = query.last {
            return model
        } else {
            return nil
        }
    }
    
    // MARK: App Version
    func getCurrentAppVersion() -> String {
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"], let build = infoDict["CFBundleVersion"] else {return ""}
        return ("Version \(version) (\(build))")
    }
    
    // MARK: Sync
    func isAutoSyncEnabled()-> Bool {
        guard let model = getModel() else {return false}
        return model.autoSyncEndbaled
    }
    
    func setAutoSync(enabled: Bool) {
        guard let model = getModel() else {return}
        AutoSync.shared.endListener()
        model.setAutoSync(enabled: enabled)
        AutoSync.shared.beginListener()
        if enabled {
            AutoSync.shared.autoSync()
        }
        
        if enabled {
            Banner.shared.show(message: "AutoSync is on")
        } else {
            Banner.shared.show(message: "AutoSync is off")
        }
    }
    
    // MARK: Map
    func clearMapData() {
        TileMaster.shared.deleteAllStoredTiles()
    }
    
    func getMapDataSize()-> String {
        return "\(TileMaster.shared.sizeOfStoredTiles().roundToDecimal(2))MB"
    }
    
    func isMapCacheEnabled()-> Bool {
        guard let model = getModel() else {return false}
        return model.cacheMapEndbaled
    }
    
    func setCacheMap(enabled: Bool) {
        guard let model = getModel() else {return}
        AutoSync.shared.endListener()
        model.setCacheMap(enabled: enabled)
        AutoSync.shared.beginListener()
    }
    
    // MARK: Enviorments
    func getCurrentEnvironment() -> EndpointEnvironment {
        guard let model = getModel() else {return .Dev}
        if model.devEnvironmentEnabled {
            return .Dev
        } else {
            return .Prod
        }
    }
    
    func setCurrentEnvironment(to mode: EndpointEnvironment, presenterReference: MainViewController) {
        guard let model = getModel() else {return}
        Alert.show(title: "Changing Environment", message: "Local data will be removed and you will be signed out.\nWould you like to continue?", yes: {
            AutoSync.shared.endListener()
            model.setDevEnvironment(enabled: mode == .Dev)
            self.signout(presenterReference: presenterReference)
        }) {
            return
        }
    }
    
    // MARK: Error Logger
    func isInAppLoggerEnabled() -> Bool {
        guard let model = getModel() else {return false}
        return model.inAppLoggerActive
    }
    
    func setInAppLoggler(enabled: Bool) {
        guard let model = getModel() else {return}
        model.setInAppLogger(enabled: enabled)
    }
    
    // MARK: Error handeling
    func shouldQuitAfterFatalError() -> Bool {
        return quitAfterFatalError
    }
    
    func setQuitAfterFatalError(enabled: Bool) {
        guard let model = getModel() else {return}
        self.quitAfterFatalError = enabled
        model.setQuitAfterFatalError(enabled: enabled)
    }
    
    // MARK: Authentication
    func signout(presenterReference: MainViewController) {
        guard let model = getModel() else {return}
        let settingsModelClone = model.clone()
        Auth.logout()
        RealmManager.shared.clearLastSyncDate()
        RealmManager.shared.clearAllData()
        RealmRequests.saveObject(object: settingsModelClone)
        Auth.refreshEnviormentConstants()
        presenterReference.chooseInitialView()
    }
    
    func setUser(firstName: String, lastName: String) {
        guard let model = getModel() else {return}
        model.setUser(firstName: firstName, lastName: lastName)
        NotificationCenter.default.post(name: .usernameUpdatedInSettings, object: nil)
        Logger.log(message: "Updated stored username:")
        Logger.log(message: getUserName(full: true))
    }
    
    func setUser(info: UserInfo) {
        setUser(firstName: info.firstName, lastName: info.lastName)
    }
    
    func getUserName(full: Bool = false) -> String {
        guard let model = getModel() else {return ""}
        var name = model.userFirstName
        if full {
            name = "\(name) \(model.userLastName)"
        }
        return name
    }
    
    func getUserInitials() -> String {
        guard let model = getModel(), let last = model.userLastName.first, let first = model.userFirstName.first else {return "RO"}
        return ("\(first)\(last)")
    }
    
    // MARK: Animations
    func setNormalAnimationSpeed() {
        guard let model = getModel() else {return}
        model.setShortAnimationDuration(to: 0.3)
        model.setAnimationDuration(to: 0.5)
    }
    
    func setFastAnimationSpeed() {
        guard let model = getModel() else {return}
        model.setShortAnimationDuration(to: 0.1)
        model.setAnimationDuration(to: 0.3)
    }
    
    func getShortAnimationDuration() -> Double {
        guard let model = getModel() else {return defaultShortAnimationDuration}
        return model.shortAnimationDuration
    }
    
    func getAnimationDuration() -> Double {
        guard let model = getModel() else {return defaultAnimationDuration}
        return model.animationDuration
    }
}
