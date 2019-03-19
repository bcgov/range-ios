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
import Reachability

class SettingsModelCache {
    
    var autoSyncEndbaled: Bool = true
    var cacheMapEndbaled: Bool = true
    
    // Dev tools
    var devToolsEnabled: Bool = false
    
    var devEnvironmentEnabled: Bool = false
    
    var quitAfterFatalError: Bool = true
    var inAppLoggerActive: Bool = false
    
    var formMapSectionActive: Bool = false
    
    // UX
    var animationDuration: Double = 0.5
    var shortAnimationDuration: Double = 0.3
    
    var userFirstName: String = ""
    var userLastName: String = ""
    
    // Remote versions
    var remoteAPIVersion: Int = 0
    var remoteIOSVersion: Int = 0
    var remoteVersionIdpHint: String = ""
    
    var loginScreen: String = ""
    
    init(from model: SettingsModel) {
        self.autoSyncEndbaled = model.autoSyncEndbaled
        self.cacheMapEndbaled = model.cacheMapEndbaled
        self.devToolsEnabled = model.devToolsEnabled
        self.devEnvironmentEnabled = model.devEnvironmentEnabled
        self.quitAfterFatalError = model.quitAfterFatalError
        self.inAppLoggerActive = model.inAppLoggerActive
        self.formMapSectionActive = model.formMapSectionActive
        self.animationDuration = model.animationDuration
        self.shortAnimationDuration = model.shortAnimationDuration
        self.userFirstName = model.userFirstName
        self.userLastName = model.userLastName
        self.remoteAPIVersion = model.remoteAPIVersion
        self.remoteIOSVersion = model.remoteIOSVersion
        self.remoteVersionIdpHint = model.remoteVersionIdpHint
        self.loginScreen = model.loginScreen
    }
}

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
    @objc dynamic var devToolsEnabled: Bool = false
    
    @objc dynamic var devEnvironmentEnabled: Bool = false
    
    @objc dynamic var quitAfterFatalError: Bool = true
    @objc dynamic var inAppLoggerActive: Bool = false
    
    @objc dynamic var formMapSectionActive: Bool = false
    
    // UX
    @objc dynamic var animationDuration: Double = 0.5
    @objc dynamic var shortAnimationDuration: Double = 0.3
    
    @objc dynamic var userFirstName: String = ""
    @objc dynamic var userLastName: String = ""
    
    // Remote versions
    @objc dynamic var remoteAPIVersion: Int = 0
    @objc dynamic var remoteIOSVersion: Int = 0
    @objc dynamic var remoteVersionIdpHint: String = ""
    
    // Force change initial login
    @objc dynamic var loginScreen: String = ""
    
    func clone() -> SettingsModel {
        let new = SettingsModel()
        new.autoSyncEndbaled = self.autoSyncEndbaled
        new.cacheMapEndbaled = self.cacheMapEndbaled
        new.devEnvironmentEnabled = self.devEnvironmentEnabled
        new.inAppLoggerActive = self.inAppLoggerActive
        new.quitAfterFatalError = self.quitAfterFatalError
        new.animationDuration = self.animationDuration
        new.shortAnimationDuration = self.shortAnimationDuration
        new.devToolsEnabled = self.devToolsEnabled
        new.formMapSectionActive = self.formMapSectionActive
        new.loginScreen = self.loginScreen
        // dont clone user name
        return new
    }
    
    func setFrom(cache: SettingsModelCache) {
        self.autoSyncEndbaled = cache.autoSyncEndbaled
        self.cacheMapEndbaled = cache.cacheMapEndbaled
        self.devToolsEnabled = cache.devToolsEnabled
        self.devEnvironmentEnabled = cache.devEnvironmentEnabled
        self.quitAfterFatalError = cache.quitAfterFatalError
        self.inAppLoggerActive = cache.inAppLoggerActive
        self.formMapSectionActive = cache.formMapSectionActive
        self.animationDuration = cache.animationDuration
        self.shortAnimationDuration = cache.shortAnimationDuration
        self.userFirstName = cache.userFirstName
        self.userLastName = cache.userLastName
        self.remoteAPIVersion = cache.remoteAPIVersion
        self.remoteIOSVersion = cache.remoteIOSVersion
        self.remoteVersionIdpHint = cache.remoteVersionIdpHint
        self.loginScreen = cache.loginScreen
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
    
    func setDevTools(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                devToolsEnabled = enabled
                if !enabled {
                    self.quitAfterFatalError = true
                    self.inAppLoggerActive = false
                    self.formMapSectionActive = false
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setFormMapSection(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                formMapSectionActive = enabled
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setRemoteVersion(from object: RemoteVersion) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteAPIVersion = object.api
                remoteIOSVersion = object.ios
                remoteVersionIdpHint = object.idpHint
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func setLoginScreen(to hint: String) {
        do {
            let realm = try Realm()
            try realm.write {
                loginScreen = hint
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
    
    /// App ingeget version is same as local db version in appdelegate's migrateRealm()
    /// (Version * 1000) + build
    ///
    /// - Returns: Integer representing application and local database version
    static func generateAppIntegerVersion() -> Int? {
        // We get version and build numbers of app
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"], let build = infoDict["CFBundleVersion"] else {
            Logger.log(message: "Could not find build version and number to generate integer app version in settings")
            return nil
        }
        // comvert tp integer
        let stringVersion = "\(version)".removeWhitespaces()
        let stringBuild = "\(build)".removeWhitespaces()
        guard let intVersion = Int(stringVersion), let intBuild = Int(stringBuild) else {
            Logger.log(message: "Could not generate integer app version in settings")
            return nil
        }
        // Generate based on version and build
        let generatedVersion = (intVersion * 1000) + intBuild
        
        return generatedVersion
    }
    
    func refreshAuthIdpHintIfNecessary(completion: @escaping(_ appVersion: ApplicationVersionStatus)-> Void) {
        func refreshAuthEviormentConstantsBaedOnStoredRemoteVersion() {
            let appVersionStatus = self.getAppVersionStatus()
            if let remoteVersion = self.getRemoteVersion(), appVersionStatus == .isLatest {
                Auth.refreshEnviormentConstants(withIdpHint: remoteVersion.idpHint)
            }
             return completion(appVersionStatus)
        }
        
        if let r = Reachability(), r.connection != .none {
            API.loadRemoteVersion { (success) in
                refreshAuthEviormentConstantsBaedOnStoredRemoteVersion()
            }
        } else {
            refreshAuthEviormentConstantsBaedOnStoredRemoteVersion()
        }
    }
    
    func appIsBeingTested(completion: @escaping(_ appIsBeingTested: Bool)-> Void) {
        SettingsManager.shared.refreshAuthIdpHintIfNecessary { (status) in
            var appIsBeingTested = false
            if status == .isLatest, let version = SettingsManager.shared.getRemoteVersion(), version.idpHint == "bceid" {
                appIsBeingTested = true
            } else if status == .isNewerThanRemote {
                appIsBeingTested = true
            }
            return completion(appIsBeingTested)
            
        }
    }
    
    func getAppVersionStatus() -> ApplicationVersionStatus {
        guard let remoteVersion = getRemoteVersion(), let localVersion = SettingsManager.generateAppIntegerVersion() else {
            return .Unfetched
        }
        Logger.log(message: "Application version status...")
        Logger.log(message: "\nAPI: \(remoteVersion.api)\niOS: \(remoteVersion.ios)\nHint: \(remoteVersion.idpHint)")
        Logger.log(message: "Local: \(localVersion)")
        
        if remoteVersion.ios == localVersion {
            return .isLatest
        } else if remoteVersion.ios > localVersion {
            return .isOld
        } else {
            return .isNewerThanRemote
        }
    }
    
    func getRemoteVersion() -> RemoteVersion? {
        guard let model = getModel(), model.remoteIOSVersion > 0 else {return nil}
        return RemoteVersion(ios: model.remoteIOSVersion, idpHint: model.remoteVersionIdpHint, api: model.remoteAPIVersion)
    }
    
    func setRemoteVersion(from object: RemoteVersion) {
        guard let model = getModel() else {return}
        model.setRemoteVersion(from: object)
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
        guard let model = getModel() else {return .Prod}
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
        Logger.log(message: "Logger window enabled: \(enabled)")
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
        AutoSync.shared.endListener()
        let settingsModelCache = SettingsModelCache(from: model)
        Auth.logout()
        
        RealmManager.shared.clearLastSyncDate()
        RealmManager.shared.clearAllData()
        let newSettings = SettingsModel()
        newSettings.setFrom(cache: settingsModelCache)
        RealmRequests.saveObject(object: newSettings)
        Auth.refreshEnviormentConstants(withIdpHint: nil)
        presenterReference.chooseInitialView()
    }
    
    // MARK: Users
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
    
    // MARK: Developer Mode
    func isDeveloperModeEnabled() -> Bool {
        guard let model = getModel() else {return false}
        return model.devToolsEnabled
    }
    
    func setDeveloperMode(enabled: Bool) {
        guard let model = getModel() else {return}
        model.setDevTools(enabled: enabled)
        if !enabled {
            Logger.log(message: "Developer mode disabled.")
            self.setInAppLoggler(enabled: enabled)
            self.setFormMapSection(enabled: enabled)
            self.setQuitAfterFatalError(enabled: enabled)
        }
    }
    
    // Overriding login screen from settings
    func setLoginScreen(to idphint: String) {
        guard let model = getModel() else {return}
        model.setLoginScreen(to: idphint)
    }
    
    func shouldOverrideLogin() -> Bool {
        guard let model = getModel() else {return false}
        if model.devToolsEnabled {
            return !model.loginScreen.isEmpty
        } else {
            return false
        }
    }
    
    func overrideLoginIfNeeded() {
        guard let model = getModel() else {return}
        if shouldOverrideLogin() {
            Auth.refreshEnviormentConstants(withIdpHint: model.loginScreen)
        }
    }
    
    func getLoginScreenHintOverride() -> String {
        guard let model = getModel() else {return ""}
        return model.loginScreen
    }
    
    // MARK: Form Map
    func isFormMapSectionEnabled() -> Bool {
        guard let model = getModel() else {return false}
        return model.formMapSectionActive
    }
    
    func setFormMapSection(enabled: Bool) {
        guard let model = getModel() else {return}
        model.setFormMapSection(enabled: enabled)
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
