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
    
    // MARK: Vatiables
    var parentReference: MainViewController?
    let reachability = Reachability()!
    
    // MARK: Outlet Actions
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var loginMessage: UILabel!
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachabilityNotification()
        style()
        styleLoginButton()
    }
    
    // MARK: Outlet Actions
    @IBAction func loginAction(_ sender: Any) {
//        self.loginButton.isUserInteractionEnabled = false
        Auth.signIn { (success) in
            if success {
                self.performInitialSync()
            }
        }
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        let settings: Settings = UIView.fromNib()
        settings.initialize(fromVC: self) {
            
        }
    }
    
    // MARK: Sync
    func performInitialSync() {
        sync { (synced) in
            if synced, let presenter = self.getPresenter() {
                presenter.chooseInitialView(initialLogin: true)
            } else {
                Auth.logout()
                self.loginButton.isUserInteractionEnabled = true
                Alert.show(title: "Unexpected error", message: "Could not perform initial Synchronization.")
            }
        }
    }
    
    // MARK: Reachability
    func setupReachabilityNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            Logger.log(message: "could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        styleLoginButton()
    }
    
    // MARK: Style
    func style() {
        styleContainer(layer: container)
        styleButton(button: loginButton)
        loginMessage.font = Fonts.getPrimaryMedium(size: 17)
        loginMessage.textColor = Colors.active.blue
        
        
        if UIDevice.current.orientation.isLandscape{
            self.whenLandscape()
        } else {
            self.whenPortrait()
        }
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
    
    override func whenPortrait() {
        bgImage.contentMode = .center
    }
    
    override func whenLandscape() {
        bgImage.contentMode = .center
    }
    
    func styleLoginButton() {
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
    
}
