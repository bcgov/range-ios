//
//  LoginViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Reachability

class LoginViewController: BaseViewController {

    var parentRef: MainViewController?
    let reachability = Reachability()!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bgImage: UIImageView!

    @IBOutlet weak var loginMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachabilityNotification()
        style()
        if UIDevice.current.orientation.isLandscape{
            self.whenLandscape()
        } else {
            self.whenPortrait()
        }

        guard let r = Reachability() else {return}
        if r.connection == .none {
            loginMessage.text = "Your device is Offline"
            loginButton.alpha = 0.5
            loginButton.isEnabled = false
        }
    }

    func setupLoginButton() {
        if loginButton == nil {return}
        guard let r = Reachability() else {return}
        if r.connection == .none {
            loginMessage.text = "Your device is Offline"
            loginButton.alpha = 0.5
            loginButton.isEnabled = false
        } else {
            loginMessage.text = ""
            loginButton.alpha = 1
            loginButton.isEnabled = true
        }
    }

    @IBAction func loginAction(_ sender: Any) {
        authenticateIfRequred()
    }

    override func onAuthenticationSuccess() {

        self.loginButton.isUserInteractionEnabled = false
        sync { (synced) in
            if synced, let parent = self.parentRef {
                parent.removeCurrentVCAndReload()
            } else {
                self.authServices.logout()
                self.loginButton.isUserInteractionEnabled = true
            }
        }
    }

    override func onAuthenticationFail() {
        self.loginButton.isUserInteractionEnabled = true
    }

    func setup(parentReference: MainViewController) {
        self.parentRef = parentReference
    }

    override func whenPortrait() {
        bgImage.contentMode = .center
    }

    override func whenLandscape() {
        bgImage.contentMode = .center
    }

    func setupReachabilityNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        setupLoginButton()
    }

}

extension LoginViewController {
    func style() {
        setStatusBarAppearanceLight()
        styleContainer(layer: container)
        styleButton(button: loginButton)
        loginMessage.font = Fonts.getPrimaryMedium(size: 17)
        loginMessage.textColor = Colors.active.blue
    }

    func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:1)
    }

    func styleContainer(layer: UIView) {
        layer.layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white
        layer.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.3).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 20
    }
}
