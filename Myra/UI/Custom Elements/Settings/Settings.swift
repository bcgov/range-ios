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
    case Map
    case Environment
}

enum SettingsSyncSection: Int, CaseIterable {
    case Autosync = 0
}

enum SettingsMapSection: Int, CaseIterable {
    case StoredSize = 0
    case AutoCache
    case ClearCache
}

enum SettingsEnvironmentSection: Int, CaseIterable {
    case Development
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
        switch indexPath.section {
        case SettingsSections.Sync.rawValue:
            switch indexPath.row {
            case SettingsSyncSection.Autosync.rawValue:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "AutoSync", isOn: SettingsManager.shared.isAutoSyncEnabled()) { (isOn) in
                    if isOn {
                        self.enableAutoSync()
                    } else {
                        SettingsManager.shared.setAutoSync(enabled: isOn)
                    }
                    
                }
                return cell
            default:
                fatalError()
            }
        case SettingsSections.Map.rawValue:
            switch indexPath.row {
            case SettingsMapSection.StoredSize.rawValue:
                let cell = getSettingInfoTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Storage Used", infoText: SettingsManager.shared.getMapDataSize())
                return cell
            case SettingsMapSection.AutoCache.rawValue:
                let cell = getSettingToggleTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Automatically Cache Map Data", isOn: SettingsManager.shared.isMapCacheEnabled()) { (isOn) in
                    SettingsManager.shared.setCacheMap(enabled: isOn)
                }
                return cell
            case SettingsMapSection.ClearCache.rawValue:
                let cell = getSettingButtonTableViewCell(indexPath: indexPath)
                cell.setup(titleText: "Clear Cached Data") {
                    SettingsManager.shared.clearMapData()
                    self.reloadMapSizeCell()
                }
                return cell
            default:
                fatalError()
            }
        case SettingsSections.Environment.rawValue:
            switch indexPath.row {
            case SettingsEnvironmentSection.Development.rawValue:
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
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSections.Sync.rawValue:
            return SettingsSyncSection.allCases.count
        case SettingsSections.Map.rawValue:
            return SettingsMapSection.allCases.count
        case SettingsSections.Environment.rawValue:
            return SettingsEnvironmentSection.allCases.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SettingsSections.Sync.rawValue:
            return "SYNCING"
        case SettingsSections.Map.rawValue:
            return "MAPPING"
        case SettingsSections.Environment.rawValue:
            return "ENVIRONMENT"
        default:
            return ""
        }
    }
}
