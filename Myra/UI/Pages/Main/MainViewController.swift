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

    // new variables. the above vars should not be necessary after new presentation stategy has been implemented.
    let presentationDuration = 0.3
    let flipDuration: Double = 0.4

    var currentViewController: UIViewController?
    var previousViewControllers: [UIViewController] = [UIViewController]()

    var leftTransitionAnimation: UIView.AnimationOptions = .curveEaseOut
    var rightTransitionAnimation: UIView.AnimationOptions = .curveEaseOut

    var transitionOptions: UIView.AnimationOptions = [.showHideTransitionViews, .transitionFlipFromLeft]

    var initialTransitionOptions: UIView.AnimationOptions = [.curveEaseIn]

    // MARK Outlets
    @IBOutlet weak var body: UIView!
    @IBOutlet weak var innerNavBar: UIView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBarBackButton: UIButton!
    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var navBarHeight: NSLayoutConstraint!

    // MARL: VC Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.removeLoggerWindowIfExists()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseInitialView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        styleNavBar()
        Logger.initializeIfNeeded()
    }

    @IBAction func navBackAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.goBack()
        }
    }
    
    func styleNavBar() {
        self.navBar.backgroundColor = Colors.primary
        self.innerNavBar.backgroundColor = Colors.primary
        self.pageTitle.font = defaultNavBarTitleFont()
        self.pageTitle.textColor = UIColor.white
        self.backIcon.image = UIImage(named: "back")
        addShadow(to: navBar.layer, opacity: 0.8, height: 2)
    }
}

extension MainViewController {
    // MARK: Nav Bar
    func hideNav() {
        self.navBarBackButton.alpha = self.invisibleAlpha
        self.backIcon.alpha = self.invisibleAlpha
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: presentationDuration) {
            self.pageTitle.isHidden = true
            self.navBarHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func showNav() {
        UIView.animate(withDuration: presentationDuration, animations: {
            self.pageTitle.isHidden = false
            self.navBarHeight.constant = 80
            self.view.layoutIfNeeded()
        }) { (done) in
            self.navBarBackButton.alpha = self.visibleAlpha
            self.backIcon.alpha = self.visibleAlpha
            self.view.layoutIfNeeded()
        }
    }

    func setNav(title: String) {
        UIView.animate(withDuration: (presentationDuration/2), animations: {
            self.pageTitle.isHidden = true
            self.view.layoutIfNeeded()
        }) { (done) in
            self.pageTitle.text = title
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: self.presentationDuration, animations: {
                self.pageTitle.isHidden = false
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

            /* Handle VCs that require special care before dismissal*/
            if let home = current as? HomeViewController {
                home.endChangeListener()
            }
//            current.dismiss(animated: true) {
//                self.present(viewController, animated: true, completion: nil)
//            }
            
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
//            present(viewController, animated: true, completion: nil)
            
            
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
