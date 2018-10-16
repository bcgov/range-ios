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

enum SyncedItem {
    case Drafts
    case Statuses
    case Outbox
}

class AutoSync {

    internal static let shared = AutoSync()
    
    var realmNotificationToken: NotificationToken?
    var isSynchronizing: Bool = false

    // MARK: Constants
    let lockScreenTag = 204

    private init() {}

    func beginListener() {
        print("Listening to db changes in AutoSync")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("change observed in AutoSync")
                if !self.isSynchronizing {
                    self.autoSync()
                } else {
                    print("But you're already synchronizing")
                }
            }
        } catch _ {
            fatalError()
        }
    }

    func endListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            print("Stopped Listening :(")
        }
    }

    func autoSync() {
        guard let r = Reachability() else {return}

        if r.connection == .none {
            print("But you're offline so bye")
            return
        }

        print("You're Online")

        if self.isSynchronizing {
            print ("but already syncing")
            return
        }

        if !self.shouldUploadOutbox() && !self.shouldUpdateRemoteStatuses() && !self.shouldUploadDrafts() {
            print("Nothing to sync")
            return
        }

        // great, if we're here then there is something to sync!
        self.isSynchronizing = true
        DispatchQueue.global(qos: .background).async {
            self.lockScreenForSync()
            var hadFails: Bool = false
            var syncedItems: [SyncedItem] = [SyncedItem]()

            let dispatchGroup = DispatchGroup()

            if self.shouldUploadOutbox() {
                dispatchGroup.enter()
                let outboxPlans = RUPManager.shared.getOutboxRups()
                API.upload(plans: outboxPlans, completion: { (success) in
                    if success {
                        syncedItems.append(.Outbox)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            if self.shouldUpdateRemoteStatuses() {
                dispatchGroup.enter()
                let updatedPlans = RUPManager.shared.getRUPsWithUpdatedLocalStatus()
                API.upload(statusesFor: updatedPlans, completion: { (success) in
                    if success {
                        syncedItems.append(.Statuses)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            if self.shouldUploadDrafts() {
                dispatchGroup.enter()
                let draftPlans = RUPManager.shared.getDraftRups()
                API.upload(plans: draftPlans, completion: { (success) in
                    if success {
                        syncedItems.append(.Drafts)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }

            // End
            dispatchGroup.notify(queue: .main) {
                Banner.shared.show(message: self.generateSyncMessage(elements: syncedItems))
                self.isSynchronizing = false
                self.removeSyncLock()
            }
        }
    }

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
            print("you're in create page")
            return false
        } else {
            print("you're not in create page")
            let drafts = RUPManager.shared.getDraftRups()
            for draft in drafts {
                if draft.canBeUploadedAsDraft() {
                    return true
                }
            }
            return false
        }
    }

    func isCreatePagePresented() -> Bool {
        /*
         getting the top most view controller should be done on main theread.
         this function can be accessed from main and background threads so we need to handle both.

         we use Thread.isMainThread to prevent a deadlock if we're already on main thread
         otherwise
         we use DispatchQueue.main.sync to get top most view controller on main thread
         Sync because we need to return synchronously
         */

        /*
        var isIt = false
        if Thread.isMainThread {
            if let currentVC = UIApplication.getTopMostViewController(), let _ = currentVC as? CreateNewRUPViewController {
                isIt = true
            }
            return isIt
        } else {
            DispatchQueue.main.sync {
                if let currentVC = UIApplication.getTopMostViewController(), let _ = currentVC as? CreateNewRUPViewController {
                    isIt = true
                }
            }
            return isIt
        }
         */

        // EDIT: we should instead check if create is presented, not just if it's the top most vc
        // 1) Home should always be root view controller.
        // 2) There is 1 case where create is not presented by home: when initially creating one
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

    func shouldUploadOutbox() -> Bool {
        return (RUPManager.shared.getOutboxRups().count > 0)
    }

    func shouldUpdateRemoteStatuses() -> Bool {
        return (RUPManager.shared.getRUPsWithUpdatedLocalStatus().count > 0)
    }

    func lockScreenForSync() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                // Create a view that fills the screen
                let view = UIView(frame: window.frame)
                view.tag = self.lockScreenTag
                window.addSubview(view)

                // add anchors to center and rotate properly
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: window.frame.width),
                    view.heightAnchor.constraint(equalToConstant: window.frame.height),
                    view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                    view.topAnchor.constraint(equalTo: window.topAnchor),
                    view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: window.leftAnchor),
                    view.rightAnchor.constraint(equalTo: window.rightAnchor)
                    ])
                // add white background
                view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: 0.9)


                // add sync icon
                let animationView = LOTAnimationView(name: "sync_icon")
                animationView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                animationView.center.y = view.center.y
                animationView.center.x = view.center.x
                animationView.contentMode = .scaleAspectFit
                animationView.loopAnimation = true
                // add subview to white screen view
                view.addSubview(animationView)
                // add anchors to center and rotate properly
                animationView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    ])
                animationView.play()
            }
        }
    }

    func removeSyncLock() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let window = UIApplication.shared.keyWindow, let view = window.viewWithTag(self.lockScreenTag), let currentVC = UIApplication.getTopMostViewController() {

                // if currentVC is home page, reload it
                if let home = currentVC as? HomeViewController {
                    home.loadHome()
                }

                view.removeFromSuperview()
            }
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
