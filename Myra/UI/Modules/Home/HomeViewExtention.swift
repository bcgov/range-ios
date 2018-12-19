//
//  HomeViewExtention.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-30.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController {
    // MARK: Logout
    func showLogoutOption(on: UIButton) {
        let vm = ViewManager()
        let lookup = vm.lookup
        let logoutOption = SelectionPopUpObject(display: "Logout", value: "logout")
        var objects = [SelectionPopUpObject]()
        objects.append(logoutOption)
        lookup.setupSimple(objects: objects) { (selected, obj) in
            if selected, let selection = obj {
                lookup.dismiss(animated: true, completion: nil)
                if selection.value == logoutOption.value, let p = self.parentReference {
                    self.showAlert(title: "Are you sure?", description: "Logging out will delete all plans that have not been synced.", yesButtonTapped: {
                        AutoSync.shared.endListener()
                        self.logout()
                        // TODO: test functionality
                        // CLEAN-FLAG
//                        p.removeCurrentVCAndReload()
                        p.chooseInitialView()
                    }, noButtonTapped: {})
                }
            } else {
                lookup.dismiss(animated: true, completion: nil)
            }
        }
        showPopOver(on: on, vc: lookup, height: lookup.getEstimatedHeight(), width: 200, arrowColor: nil)
    }
}
