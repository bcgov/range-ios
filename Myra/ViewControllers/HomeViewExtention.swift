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
        lookup.setup(objects: objects) { (selected, obj) in
            if selected, let selection = obj {
                if selection.value == logoutOption.value, let p = self.parentReference {
                    self.logout()
                    p.removeCurrentVCAndReload()
                }
                
                lookup.dismiss(animated: true, completion: nil)
            } else {
                lookup.dismiss(animated: true, completion: nil)
            }
        }
        showPopOver(on: on, vc: lookup, height: lookup.getEstimatedHeight(), width: 200, arrowColor: nil)
    }
}
