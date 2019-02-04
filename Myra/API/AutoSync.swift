//
//  AutoSync.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Reachability
import Realm
import RealmSwift
import Lottie
import Extended
import SingleSignOn

enum SyncedItem {
    case Drafts
    case Statuses
    case Outbox
}

class AutoSync {

    internal static let shared = AutoSync()
    
    var realmNotificationToken: NotificationToken?
    var isSynchronizing: Bool = false
    var manualSyncRequiredShown = false

    private init() {}

    // MARK: AutoSync Listener
    func beginListener() {

        Logger.log(message: "Listening to database changes in AutoSync.")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                Logger.log(message: "Change observed in AutoSync...")
                if !SettingsManager.shared.isAutoSyncEnabled() {
                    Logger.log(message: "But Autosync is blocked.")
                    return
                }
                if let r = Reachability(), r.connection == .none {
                    Logger.log(message: "But you're offline.")
                    return
                }
                if !self.isSynchronizing {
                    self.autoSync()
                } else {
                    Logger.log(message: "But you're already synchronizing.")
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databseChangeListenerFailure)
        }
    }

    func endListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            Logger.log(message: "Stopped listening to database changes in AutoSync.")
        }
    }

    // MARK AutoSync Action
    func autoSync() {
        if !shouldAutoSync() {
            return
        }
        
        Logger.log(message: "Executing Autosync...")

        // set some variables
        self.manualSyncRequiredShown = false
        self.isSynchronizing = true
        
        // Add the autosync view
        let autoSyncView: AutoSyncView = UIView.fromNib()
        autoSyncView.initialize()
        // Lets move to a background thread
        DispatchQueue.global(qos: .background).async {
            
            var syncedItems: [SyncedItem] = [SyncedItem]()

            let dispatchGroup = DispatchGroup()

            // Outbox
            if self.shouldUploadOutbox() {
                dispatchGroup.enter()
                let outboxPlans = RUPManager.shared.getOutboxRups()
                API.upload(plans: outboxPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uploaded outbox plans")
                        syncedItems.append(.Outbox)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            // Statuses
            if self.shouldUpdateRemoteStatuses() {
                dispatchGroup.enter()
                let updatedPlans = RUPManager.shared.getRUPsWithUpdatedLocalStatus()
                API.upload(statusesFor: updatedPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uplodated statuses")
                        syncedItems.append(.Statuses)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            // Drafts
            if self.shouldUploadDrafts() {
                dispatchGroup.enter()
                let draftPlans = RUPManager.shared.getDraftRupsValidForUpload()
                API.upload(plans: draftPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uploaded drafts")
                        syncedItems.append(.Drafts)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            // End
            dispatchGroup.notify(queue: .main) {
                Logger.log(message: "Autosync Executed.")
                
                // if home page is presented, reload its content
                if let home = self.getPresentedHome() {
                    Logger.log(message: "Reloading plans in home page after autosync")
                    home.loadRUPs()
                }
                
                // Display a banner.
                Banner.shared.show(message: self.generateSyncMessage(elements: syncedItems))
                
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    autoSyncView.remove()
                    // free autosync
                    self.isSynchronizing = false
                }
            }
        }
    }
    
    // MARK Criteria
    func shouldAutoSync() -> Bool {
        Logger.log(message: "Checking if Autosync should be executed...")
        guard let r = Reachability() else {
            Logger.log(message: "No. Can't check connectivity offline.")
            return false
        }
        
        if !SettingsManager.shared.isAutoSyncEnabled() {
            Logger.log(message: "No. Autosync is blocked.")
            return false
        }
        
        if r.connection == .none {
            Logger.log(message: "No. You're offline.")
            return false
        }
        
        if self.isSynchronizing {
            Logger.log(message: "No. A sync is in progress.")
            return false
        }
        
        if !self.shouldUploadOutbox() && !self.shouldUpdateRemoteStatuses() && !self.shouldUploadDrafts() {
            Logger.log(message: "No. Nothing to sync")
            return false
        }
        
        if !Auth.isAuthenticated() {
            Logger.log(message: "No. You're not authenticated.")
            Logger.log(message: "Showung options")
            if !manualSyncRequiredShown {
                manualSyncRequiredShown = true
                Alert.show(title: "Authentication Required", message: "You have plans that need to be synced.\n Would you like to authenticate now and synchronize?\n\nIf you select no, Autosync will be turned off.\nAutosync can be turned on and off in the settings page.", yes: {
                    Auth.authenticate(completion: { (success) in
                        if success {
                            self.autoSync()
                        }
                    })
                }) {
                    SettingsManager.shared.setAutoSync(enabled: false)
                    Banner.shared.show(message: Messages.AutoSync.manualSyncRequired)
                }
            }
            return false
        }
        
        
        return true
    }
    
    func shouldUploadOutbox() -> Bool {
        return (RUPManager.shared.getOutboxRups().count > 0)
    }
    
    func shouldUpdateRemoteStatuses() -> Bool {
        return (RUPManager.shared.getRUPsWithUpdatedLocalStatus().count > 0)
    }

    // MARK: Messages
    func generateSyncMessage(elements: [SyncedItem]) -> String {
        var body: String = ""
        for element in elements {
            let new = "\(body)\(element)"
            body = "\(new), "
        }

        // clean it up
        body = body.replacingLastOccurrenceOfString(",", with: "")
        body = body.replacingLastOccurrenceOfString(" ", with: ".")

        // if we only had 2 elements, replace the comma with and
        body = body.replacingLastOccurrenceOfString(",", with: " and")

        if body.isEmpty {
            return ""
        } else {
            return "AutoSynced \(body)"
        }
    }

    func shouldUploadDrafts() -> Bool {
        // Should not upload drafts if we're in create page: might be editing the draft
        if isCreatePagePresented() {
            Logger.log(message: "Should not upload drafts when from page is presented.")
            return false
        } else {
            let drafts = RUPManager.shared.getDraftRups()
            for draft in drafts {
                if draft.canBeUploadedAsDraft() {
                    return true
                }
            }
            return false
        }
    }
    
    // MARK: Other criteria
    func isCreatePagePresented() -> Bool {
        var isIt = false
        if Thread.isMainThread {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController, let presented = home.presentedViewController {
                if presented is CreateNewRUPViewController {
                    isIt = true
                } else if presented is SelectAgreementViewController, let presentedDeeper = presented.presentedViewController, presentedDeeper is CreateNewRUPViewController {
                    isIt = true
                }
            }
            return isIt
        } else {
            DispatchQueue.main.sync {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController, let presented = home.presentedViewController {
                    if presented is CreateNewRUPViewController {
                        isIt = true
                    } else if presented is SelectAgreementViewController, let presentedDeeper = presented.presentedViewController, presentedDeeper is CreateNewRUPViewController {
                        isIt = true
                    }
                }
            }
            return isIt
        }
    }

    func isHomePagePresented() -> Bool {
        var isIt = false
        if Thread.isMainThread {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController {
                    isIt = true
            }
            return isIt
        } else {
            DispatchQueue.main.sync {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController {
                    isIt = true
                }
            }
            return isIt
        }
    }

    func getPresentedHome() -> HomeViewController? {
        var homeVC: HomeViewController? = nil
        if Thread.isMainThread {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController, let h = home as? HomeViewController {
                homeVC = h
            }
            return homeVC
        } else {
            DispatchQueue.main.sync {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window, let root = window.rootViewController, let home = root.children.first, home is HomeViewController, let h = home as? HomeViewController {
                    homeVC = h
                }
            }
            return homeVC
        }
    }
    
    private static func getCurrentViewController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow else {return nil}
        if var topController = window.rootViewController {
            while let presentedVC = topController.presentedViewController {
                topController = presentedVC
            }
            return topController
        } else {
            return nil
        }
    }
}

extension UIApplication {
    public class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
