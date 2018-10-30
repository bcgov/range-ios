  //
//  LoginViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    var parentRef: MainViewController?
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bgImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        if UIDevice.current.orientation.isLandscape{
            self.whenLandscape()
        } else {
            self.whenPortrait()
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

}

extension LoginViewController {
    func style() {
        setStatusBarAppearanceLight()
        styleContainer(layer: container)
        styleButton(button: loginButton)
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
