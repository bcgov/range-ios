//
//  MainViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {

    // MARK: Variables
    var currentChildVC: UIViewController?
    var nextChildVC: UIViewController?
    var loginDisplayed: Bool = false

    // new variables. the above vars should not be necessary after new presentation stategy has been implemented.
    let presentationDuration = 0.3
    let flipDuration: Double = 0.4

    var currentViewController: UIViewController?
    var previousViewControllers: [UIViewController] = [UIViewController]()

    var leftTransitionAnimation: UIView.AnimationOptions = .transitionFlipFromLeft
    var rightTransitionAnimation: UIView.AnimationOptions = .transitionFlipFromRight

    var transitionOptions: UIView.AnimationOptions = [.showHideTransitionViews, .transitionFlipFromLeft]

    var initialTransitionOptions: UIView.AnimationOptions = [.curveEaseIn]

    // MARK Outlets
    @IBOutlet weak var body: UIView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBarBackButton: UIButton!
    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var navBarHeight: NSLayoutConstraint!

    // MARL: VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseInitialView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func navBackAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.goBack()
        }
    }
}

extension MainViewController {
    
    func chooseInitialView() {
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
        vc.setPresenter(viewController: self)
        show(viewController: vc)
    }

    func showCreateNew() {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.selectAgreement
        vc.setPresenter(viewController: self)
        show(viewController: vc)
    }

    func showForm(for plan: Plan, mode: FormMode) {
        transitionOptions = [.showHideTransitionViews, leftTransitionAnimation]
        let vm = ViewManager()
        let vc = vm.createRUP
        vc.setPresenter(viewController: self)
        vc.setup(rup: plan, mode: mode) { (closed, cancel) in
            self.showHome()
        }
        show(viewController: vc)
    }

    func showScheduleDetails(for schedule: Schedule, in plan: Plan, mode: FormMode) {
        let vm = ViewManager()
        let vc = vm.schedule
        AutoSync.shared.endListener()
        vc.setup(mode: mode, rup: plan, schedule: schedule, completion: { done in
            AutoSync.shared.beginListener()
            self.goBack()
        })
        show(viewController: vc)
    }

    func showPlanCommunityDetails(for plantCommunity: PlantCommunity, of pasture: Pasture, in plan: Plan, mode: FormMode) {
        let vm = ViewManager()
        let vc = vm.plantCommunity
        AutoSync.shared.endListener()
        vc.setup(mode: mode, plan: plan, pasture: pasture, plantCommunity: plantCommunity, completion: { done in
            AutoSync.shared.beginListener()
            self.goBack()
        })
        show(viewController: vc)
    }
}

extension MainViewController {
    // MARK: Nav Bar
    func hideNav() {
        self.navBarBackButton.alpha = 0
        self.backIcon.alpha = 0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: presentationDuration) {
            self.pageTitle.alpha = 0
            self.navBarHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func showNav() {
        UIView.animate(withDuration: presentationDuration, animations: {
            self.pageTitle.alpha = 1
            self.navBarHeight.constant = 73
            self.view.layoutIfNeeded()
        }) { (done) in
            self.navBarBackButton.alpha = 1
            self.backIcon.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    func setNav(title: String) {
        UIView.animate(withDuration: presentationDuration, animations: {
            self.pageTitle.alpha = 0
            self.view.layoutIfNeeded()
        }) { (done) in
            self.pageTitle.text = title
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: self.presentationDuration, animations: {
                self.pageTitle.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }

    func goBack() {
        transitionOptions = [.showHideTransitionViews, rightTransitionAnimation]
        removeCurrentVC()
    }

    func goHome() {
        if let current = previousViewControllers.popLast() {
            previousViewControllers.removeAll()
            remove(asChildViewController: current)
            showHome()
        }
    }

    // MARK: Adding and removing viewControllers mechanic
    func show(viewController: UIViewController, addToStack: Bool? = true) {
        if let current = self.currentViewController {
            self.view.layoutIfNeeded()
            self.addChild(viewController)
            viewController.view.frame = self.body.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.body.addSubview(viewController.view)
            viewController.didMove(toParent: self)

            UIView.transition(from: current.view, to: viewController.view, duration: flipDuration, options: transitionOptions) { (done) in
                self.remove(asChildViewController: current)
            }

        } else {
            self.addChild(viewController)
            viewController.view.frame = self.body.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.body.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }

        self.currentViewController = viewController
        self.previousViewControllers.append(viewController)

        /* Choose when to show / hide navigation */
        if viewController is LoginViewController || viewController is HomeViewController || viewController is CreateNewRUPViewController {
            self.hideNav()
        } else {
            self.showNav()
        }

    }

    func removeCurrentVC() {
        if let current = self.previousViewControllers.popLast() {
            remove(asChildViewController: current)
            if let previous = self.previousViewControllers.popLast() {
                show(viewController: previous)
            }
        }
    }

    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
