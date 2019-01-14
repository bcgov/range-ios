//
//  Router.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-31.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension MainViewController {

    func chooseInitialView() {
        previousViewControllers.removeAll()
        if let _ = RealmManager.shared.getLastSyncDate() {
            // Go to home page
            showHome()
        } else {
            // last sync doesn't exist.
            // Go to login page
            showLogin()
        }
    }

    func showLogin() {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.login
        vc.setup(parentReference: self)
        self.loginDisplayed = true
        vc.setPresenter(viewController: self)
        show(viewController: vc, addToStack: false)
    }

    func showHome() {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.home
        vc.parentReference = self
        vc.presentedAfterLogin = loginDisplayed
        
        AutoSync.shared.beginListener()
        vc.setPresenter(viewController: self)
        
        show(viewController: vc)
    }

    func showCreateNew() {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.selectAgreement
        vc.navigationTitle = "Create new RUP"
        
        AutoSync.shared.endListener()
        vc.setPresenter(viewController: self)
        
        show(viewController: vc)
    }

    func showForm(for plan: Plan, mode: FormMode) {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.createRUP
        
        AutoSync.shared.endListener()
        vc.setPresenter(viewController: self)

        vc.setup(rup: plan, mode: mode)

        show(viewController: vc)
    }

    func showScheduleDetails(for schedule: Schedule, in plan: Plan, mode: FormMode) {
        let vm = ViewManager()
        let vc = vm.schedule
        
        AutoSync.shared.endListener()
        vc.setPresenter(viewController: self)
        
        vc.setup(mode: mode, rup: plan, schedule: schedule)
        show(viewController: vc)
    }

    func showPlanCommunityDetails(for plantCommunity: PlantCommunity, of pasture: Pasture, in plan: Plan, mode: FormMode) {
        let vm = ViewManager()
        let vc = vm.plantCommunity
        vc.navigationTitle = "Plant Community Details"
        
        AutoSync.shared.endListener()
        vc.setPresenter(viewController: self)
        
        vc.setup(mode: mode, plan: plan, pasture: pasture, plantCommunity: plantCommunity)
        show(viewController: vc)
    }
}
