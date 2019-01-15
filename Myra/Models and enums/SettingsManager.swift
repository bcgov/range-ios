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
    @objc dynamic var devEnvironmentEnabled: Bool = true
    
    func clone() -> SettingsModel {
        let new = SettingsModel()
        new.autoSyncEndbaled = self.autoSyncEndbaled
        new.cacheMapEndbaled = self.cacheMapEndbaled
        new.devEnvironmentEnabled = self.devEnvironmentEnabled
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
            fatalError()
        }
    }
    
    func setCacheMap(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                cacheMapEndbaled = enabled
            }
        } catch _ {
            fatalError()
        }
    }
    
    func setDevEnvironment(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                devEnvironmentEnabled = enabled
            }
        } catch _ {
            fatalError()
        }
    }
}

enum EndpointEnvironment {
    case Dev
    case Prod
}


class SettingsManager {
    static let shared = SettingsManager()

    private init() {
        if getModel() == nil {
            let newModel = SettingsModel()
            RealmRequests.saveObject(object: newModel)
        }
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
            let settingsModelClone = model.clone()
            API.authServices().logout()
            RealmManager.shared.clearLastSyncDate()
            RealmManager.shared.clearAllData()
            RealmRequests.saveObject(object: settingsModelClone)
            presenterReference.chooseInitialView()
        }) {
            return
        }
    }
}
