//
//  Settings.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit
import SingleSignOn

enum SettingsSections: Int, CaseIterable {
    case Sync = 0
    case Account
    case Map
    case DeveloperTools
    case Privacy
}

enum SettingsSyncSection: Int, CaseIterable {
    case Autosync = 0
}

enum SettingsMapSection: Int, CaseIterable {
    case StoredSize = 0
    case AutoCache
    case ClearCache
}

enum SettingsAccountSection: Int, CaseIterable {
    case UpdateUserInfo = 0
}

enum SettingsPrivacySection: Int, CaseIterable {
    case privacy = 0
}


enum SettingsDeveloperToolsSection: Int, CaseIterable {
    case Development = 0
    case LogWindow
    case ClearUserInfo
}

class Settings: CustomModal {
    
    // MARK: Variables
    var callBack: (()-> Void)?
    var parent: BaseViewController?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: Outlet Actions
    @IBAction func doneAction(_ sender: UIButton) {
        self.remove()
        if let callBack = self.callBack {
            return callBack()
        }
    }
    
    // MARK: Entry Point
    func initialize(fromVC: BaseViewController, callBack: @escaping ()-> Void) {
        setUpTable()
        self.parent = fromVC
        self.callBack = callBack
        setSmartSizingWith(percentHorizontalPadding: 20, percentVerticalPadding: 20)
        self.recursivelyRemoveWhiteScreens(attempt: true)
        style()
        present()
        autoFill()
    }
    
    func autoFill() {
        versionLabel.text = SettingsManager.shared.getCurrentAppVersion()
    }
    
    func style() {
        versionLabel.textColor = Colors.technical.bodyText
        versionLabel.font = Fonts.getPrimary(size: 17)
        styleModalBox(with: viewTitle, closeButton: doneButton)
    }
    
    // MARK: AutoSync Option
    func enableAutoSync() {
        // TODO: Move Logic to SettingsManager
        if !Auth.isAuthenticated() {
            self.hide()
            Auth.authenticate { (success) in
                self.show()
                if success {
                    SettingsManager.shared.setAutoSync(enabled: true)
                    self.reloadAutoSyncCell()
                }
            }
        } else {
            SettingsManager.shared.setAutoSync(enabled: true)
            self.reloadAutoSyncCell()
        }
    }
    
    func reloadAutoSyncCell() {
        let sizeInfoIndexPath: IndexPath = IndexPath(row: SettingsSyncSection.Autosync.rawValue, section: SettingsSections.Sync.rawValue)
        self.tableView.reloadRows(at: [sizeInfoIndexPath], with: .automatic)
    }
    
    func reloadMapSizeCell() {
        let sizeInfoIndexPath: IndexPath = IndexPath(row: SettingsMapSection.StoredSize.rawValue, section: SettingsSections.Map.rawValue)
        self.tableView.reloadRows(at: [sizeInfoIndexPath], with: .automatic)
    }
    
}

extension Settings:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "SettingTableViewCell")
        registerCell(name: "SettingInfoTableViewCell")
        registerCell(name: "SettingButtonTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getSettingToggleTableViewCell(indexPath: IndexPath) -> SettingTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
    }
    
    func getSettingInfoTableViewCell(indexPath: IndexPath) -> SettingInfoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SettingInfoTableViewCell", for: indexPath) as! SettingInfoTableViewCell
    }
    
    func getSettingButtonTableViewCell(indexPath: IndexPath) -> SettingButtonTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SettingButtonTableViewCell", for: indexPath) as! SettingButtonTableViewCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellType = SettingsSections(rawValue: Int(indexPath.section)) {
            switch cellType {
            case .Sync:
                return getSyncSection(cellForRowAt: indexPath)
            case .Account:
                return getAccountSection(cellForRowAt: indexPath)
            case .Map:
                return getMapSection(cellForRowAt: indexPath)
            case .DeveloperTools:
                return getDevToolsSection(cellForRowAt: indexPath)
            case .Privacy:
                return getPrivacySection(cellForRowAt: indexPath)
            }
        } else {
            fatalError()
        }
    }
    
    func getSyncSection(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = SettingsSyncSection(rawValue: Int(indexPath.row)) {
            switch cellType {
            case .Autosync:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "AutoSync", isOn: SettingsManager.shared.isAutoSyncEnabled()) { (isOn) in
                    if isOn {
                        self.enableAutoSync()
                    } else {
                        SettingsManager.shared.setAutoSync(enabled: isOn)
                    }
                }
                return cell
            }
        } else {
            fatalError()
        }
    }
    
    func getAccountSection(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = SettingsAccountSection(rawValue: Int(indexPath.row)) {
            switch cellType {
            case .UpdateUserInfo:
                let cell = getSettingButtonTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Update User Information") {
                    let dialog: GetNameDialog = UIView.fromNib()
                    self.remove()
                    dialog.initialize {}
                }
                return cell
            }
        } else {
            fatalError()
        }
    }
    
    func getMapSection(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = SettingsMapSection(rawValue: Int(indexPath.row)) {
            switch cellType {
            case .StoredSize:
                let cell = getSettingInfoTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Storage Used", infoText: SettingsManager.shared.getMapDataSize())
                return cell
            case .AutoCache:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Automatically Cache Map Data", isOn: SettingsManager.shared.isMapCacheEnabled()) { (isOn) in
                    SettingsManager.shared.setCacheMap(enabled: isOn)
                }
                return cell
            case .ClearCache:
                let cell = getSettingButtonTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Clear Cached Data") {
                    SettingsManager.shared.clearMapData()
                    self.reloadMapSizeCell()
                }
                return cell
            }
        } else {
            fatalError()
        }
    }
    
    func getDevToolsSection(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = SettingsDeveloperToolsSection(rawValue: Int(indexPath.row)) {
            switch cellType {
                
            case .Development:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Development", isOn: SettingsManager.shared.getCurrentEnvironment() == .Dev) { (isOn) in
                    if let parent = self.parent, let presenter = parent.getPresenter() {
                        var env: EndpointEnvironment = .Dev
                        if !isOn {
                            env = .Prod
                        }
                        SettingsManager.shared.setCurrentEnvironment(to: env, presenterReference: presenter)
                        self.remove()
                    }
                }
                return cell
            case .LogWindow:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Log Window", isOn: SettingsManager.shared.isInAppLoggerEnabled()) { (isOn) in
                    SettingsManager.shared.setInAppLoggler(enabled: isOn)
                    if !isOn {
                        Logger.loggerWindow = nil
                    }
                }
                return cell
            case .ClearUserInfo:
                let cell = getSettingButtonTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Clear User Info") {
                    API.updateUserInfo(firstName: "", lastName: "", completion: { (done) in
                        if done {
                            Alert.show(title: "Success", message: "Cleared user information")
                        } else {
                            Alert.show(title: "Failed", message: "Could not clear user information")
                        }
                    })
                }
                return cell
            }
        } else {
            fatalError()
        }
    }
    
    func getPrivacySection(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = SettingsPrivacySection(rawValue: Int(indexPath.row)) {
            switch cellType {
            case .privacy:
                let cell = getSettingButtonTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "View Privacy information") {
                    let privacy: Privacy = UIView.fromNib()
                    privacy.initialize()
                }
                return cell
            }
        } else {
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cellType = SettingsSections(rawValue: section) {
            switch cellType {
            case .Sync:
                return SettingsSyncSection.allCases.count
            case .Map:
                return SettingsMapSection.allCases.count
            case .DeveloperTools:
                return SettingsDeveloperToolsSection.allCases.count
            case .Privacy:
                return SettingsPrivacySection.allCases.count
            case .Account:
                return SettingsAccountSection.allCases.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let cellType = SettingsSections(rawValue: section) {
            switch cellType {
            case .Sync:
                return "SYNCING"
            case .Map:
                return "MAPPING"
            case .DeveloperTools:
                return "DEVELOPER TOOLS"
            case .Privacy:
                return "PRIVACY"
            case .Account:
                return "ACCOUNT"
            }
        } else {
            return ""
        }
    }
}
