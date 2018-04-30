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

    var currentVC: UIViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseInitialView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        chooseInitialView()
    }
}

extension MainViewController {
    func chooseInitialView() {
        let lastSync = RealmManager.shared.getLastSyncDate()
        print(lastSync ?? "nil")
        if lastSync != nil && authServices.isAuthenticated() {
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
        add(asChildViewController: vm.login)
    }

    func showHomePage() {
        let vm = ViewManager()
        let home = vm.home
        home.parentReference = self
        add(asChildViewController: vm.home)
    }
}

extension MainViewController {
    func add(asChildViewController viewController: UIViewController) {
        self.currentVC = viewController
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
        if self.currentVC == nil {return}
        self.currentVC?.willMove(toParentViewController: nil)
        self.currentVC?.view.removeFromSuperview()
        self.currentVC?.removeFromParentViewController()
    }

    func removeCurrentVCAndReload() {
        if self.currentVC == nil {return}
        self.currentVC?.willMove(toParentViewController: nil)
        self.currentVC?.view.removeFromSuperview()
        self.currentVC?.removeFromParentViewController()
        self.chooseInitialView()
    }

    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}
