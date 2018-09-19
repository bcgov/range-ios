//
//  MainViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {

    @IBOutlet weak var container: UIView!

    var currentChildVC: UIViewController?

    var nextChildVC: UIViewController?

    var loginDisplayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseInitialView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension MainViewController {
    func chooseInitialView() {
        if let _ = RealmManager.shared.getLastSyncDate() {
            // Go to home page
            showHomePage()
        } else {
            // last sync doesn't exist.
            // Go to login page
            showLoginPage()
        }
    }
    
    func showLoginPage() {
        let vm = ViewManager()
        let loginVC = vm.login
        loginVC.setup(parentReference: self)
        self.loginDisplayed = true
        add(asChildViewController: vm.login)
    }

    func showHomePage() {
        let vm = ViewManager()
        let home = vm.home
        home.parentReference = self
        home.presentedAfterLogin = loginDisplayed
        add(asChildViewController: vm.home)
    }


    //// Unused
    func showSelectAgreementPage() {
        let vm = ViewManager()
        let selectAgreement = vm.selectAgreement
        selectAgreement.setup(callBack: { closed in
            self.showHomePage()
        })
        add(asChildViewController: selectAgreement)
    }

    func showPlanForm(for plan: RUP, mode: FormMode) {
        let vm = ViewManager()
        let createPage = vm.createRUP
        createPage.setup(rup: plan, mode: mode) { (close, cancel) in
            self.showHomePage()
        }
        add(asChildViewController: createPage)
    }
    ////

}

extension MainViewController {
    func add(asChildViewController viewController: UIViewController) {
        self.currentChildVC = viewController
        addChildViewController(viewController)
        self.container.addSubview(viewController.view)
        viewController.view.frame = self.container.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }

    func removeSubviews() {
        let subviews = container.subviews
        for sub in subviews {
            sub.removeFromSuperview()
        }
        self.chooseInitialView()
    }

    func removeCurrentVC() {
        guard let currentChildVC = self.currentChildVC else {return}
        remove(asChildViewController: currentChildVC)
    }

    func removeCurrentVCAndReload() {
        guard let currentChildVC = self.currentChildVC else {return}
        remove(asChildViewController: currentChildVC)
        self.chooseInitialView()
    }

    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}
