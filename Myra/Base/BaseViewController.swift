//
//  BaseViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Lottie
import SingleSignOn

class BaseViewController: UIViewController {

    var loading: UIImageView?
    var loadingImages = [UIImage]()
    let authServices: AuthServices = {
        return AuthServices(baseUrl: SingleSignOnConstants.SSO.baseUrl, redirectUri: SingleSignOnConstants.SSO.redirectUri,
                            clientId: SingleSignOnConstants.SSO.clientId, realm:SingleSignOnConstants.SSO.realmName,
                            idpHint: SingleSignOnConstants.SSO.idpHint)
    }()

    var authenticated: Bool = false {
        didSet{
            if authenticated {
                whenAuthenticated()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if loadingImages.count != 4 {
            setupLoadingIndicatorImages()
        }
    }

    func whenSyncClosed() {}
    func whenAuthenticated() {}

    func whenLandscape() {}
    func whenPortrait() {}

}

extension BaseViewController {
    func getLoginView() -> UIView {
        let view = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: self.view.frame.width, height: self.view.frame.height))
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.alpha = 1

        return view
    }
}

// Loading Spinner
extension BaseViewController {
    func setupLoadingIndicatorImages() {
        var images = [UIImage]()

        for i in 0...3 {
            images.append(UIImage(named: "cow\(i)")!)
        }
        loadingImages = images
    }

    func getIoadingView() -> UIImageView {
        let view = UIImageView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 100, height: 100))
        view.animationImages = loadingImages
        view.animationDuration = 0.3
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.alpha = 1
        return view
    }

    // TODO: currently unused. reposition loading spinner.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            if UIDevice.current.orientation.isLandscape{
                print("Landscape")
                self.whenLandscape()
            } else {
                print("Portrait")
                self.whenPortrait()
            }
        }
    }
}

// Alerts
extension BaseViewController {
    
    func showAlert(with title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        ac.addAction(cancel)

        present(ac, animated: true, completion: nil)
    }
}

// Styles
extension BaseViewController {
    func addShadow(layer: CALayer) {
        layer.borderColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
    }

    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }
}

// Animations
extension BaseViewController {
    func animateIt() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func animateFor(time: Double) {
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// Status Bar Appearance
extension BaseViewController {
    func setStatusBarAppearanceLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    func setStatusBarAppearanceDark() {
        UIApplication.shared.statusBarStyle = .default
    }
}

// Sync view
extension BaseViewController {

    // White screen's tag = 100
    // View's title = 101
    // View's description = 102
    // button's tag = 103
    // Container's tag = 104
    // animation's tag = 105
    // success animation's tag = 106
    // fail animation's tag = 107
    func getSyncView() -> UIView {
        // white screen
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.9)
        view.alpha = 1

        // view that holds content
        let layerWidth: CGFloat = 400
        let layerHeight: CGFloat = 390
        let layer = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: layerWidth, height: layerHeight))
        layer.layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white
        layer.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 10
        layer.center.x = self.view.center.x
        layer.center.y = self.view.center.y
        layer.tag = 104

        // title layer
        let textLayerWidth: CGFloat = layerWidth
        let textLayerHeight: CGFloat = 26
        let textLayerTopPadding: CGFloat = 5
        let textLayer = UILabel(frame: CGRect(x: 0, y: textLayerTopPadding, width: textLayerWidth, height: textLayerHeight))
        textLayer.lineBreakMode = .byWordWrapping
        textLayer.numberOfLines = 1
        textLayer.textColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:1)
        textLayer.attributedText = getSycnTitleText(text: "Sync Changes")
        textLayer.textAlignment = .center

        textLayer.tag = 101
        // add to layer that holds content
        layer.addSubview(textLayer)

        // separator layer
        let separatorHeight: CGFloat = 1
        let separatorTopPadding: CGFloat = 5
        let separatorY: CGFloat = textLayerTopPadding + textLayerHeight
        let separator = UIView(frame: CGRect(x: 0, y: separatorY + separatorTopPadding, width: layer.frame.width, height: separatorHeight))
        separator.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        // add to layer that holds content
        layer.addSubview(separator)

        // description text
        let descWidth: CGFloat = layerWidth
        let descHeight: CGFloat = 22
        let descLayerTopPadding = separatorY + 10
        let descLayer = UILabel(frame: CGRect(x: 0, y: descLayerTopPadding, width: descWidth, height: descHeight))
        descLayer.lineBreakMode = .byWordWrapping
        descLayer.numberOfLines = 1
        descLayer.textColor = UIColor.black
        descLayer.attributedText = getSycDescriptionText(text: "")
        descLayer.textAlignment = .center

        descLayer.tag = 102
        // add to layer that holds content
        layer.addSubview(descLayer)

        // button
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 100
        let buttonButtomPadding: CGFloat = 5
        let button = UIButton(frame: CGRect(x: (layer.frame.width/2) - (buttonWidth/2), y: layerHeight - buttonHeight - buttonButtomPadding, width: buttonWidth, height: buttonHeight))
        button.backgroundColor = .white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:1).cgColor
        button.layer.cornerRadius = 5
        button.setTitle("Close", for: .normal)
        button.setTitleColor(UIColor(red:0.14, green:0.25, blue:0.46, alpha:1), for: .normal)
        button.addTarget(self, action: #selector(syncLayerButtonAction), for: .touchUpInside)

        button.tag = 103
        // add to layer that holds content
        layer.addSubview(button)

        let spinnerWidth: CGFloat = 200
        let animationView = LOTAnimationView(name: "spinner_")
        animationView.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.tag = 105
        animationView.alpha = 0
        layer.addSubview(animationView)

        let animationView2 = LOTAnimationView(name: "checked_done_")
        animationView2.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView2.contentMode = .scaleAspectFit
        animationView2.loopAnimation = false
        animationView2 .tag = 106
        animationView2.alpha = 0
        layer.addSubview(animationView2)

        let animationView3 = LOTAnimationView(name: "x_pop")
        animationView3.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView3.contentMode = .scaleAspectFit
        animationView3.loopAnimation = false
        animationView3.tag = 107
        animationView3.alpha = 0
        layer.addSubview(animationView3)

        // add layer that holds content to gray screen
        view.addSubview(layer)

        // give the view that contains it all (white screen)
        view.tag = 100

        return view
    }

    func beginSyncLoadingAnimation() {
        if let animationView = self.view.viewWithTag(105) as? LOTAnimationView {
            animationView.alpha = 1
            animationView.play()
        }
    }

    func endSyncLoadingAnimation() {
        if let loadingView = self.view.viewWithTag(105) as? LOTAnimationView {
            loadingView.alpha = 0
        }
    }

    func successLoadingAnimation() {
        if let done = self.view.viewWithTag(106) as? LOTAnimationView {
            done.play()
            done.alpha = 1
        }
    }

    func failLoadingAnimation() {
        if let err = self.view.viewWithTag(107) as? LOTAnimationView {
            err.alpha = 1
            err.play()
        }
    }

    func updateSyncDescription(text: String) {
        if let viewWithTag = self.view.viewWithTag(102) as? UILabel {
            viewWithTag.attributedText = getSycDescriptionText(text: text)
            viewWithTag.textAlignment = .center
        }
    }

    func updateSyncTitle(text: String) {
        if let label = self.view.viewWithTag(101) as? UILabel {
            label.attributedText = getSycnTitleText(text: text)
        }
    }

    func updateSyncButtonTitle(text: String) {
        if let button = self.view.viewWithTag(103) as? UIButton {
            button.setTitle(text, for: .normal)
        }
    }

    func disableSyncViewButton() {
        if let button = self.view.viewWithTag(103) as? UIButton {
            button.isEnabled = false
        }
    }

    func enableSyncViewButton() {
        if let button = self.view.viewWithTag(103) as? UIButton {
            button.isEnabled = true
        }
    }

    func showSyncViewButton() {
        if let button = self.view.viewWithTag(103) as? UIButton {
            button.alpha = 1
        }
    }

    func hideSyncViewButton() {
        if let button = self.view.viewWithTag(103) as? UIButton {
            button.alpha = 0
        }
    }

    func getSycDescriptionText(text: String) ->  NSMutableAttributedString {
        let textContent = text
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.29
        textString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: textRange)
        return textString
    }

    func getSycnTitleText(text: String) ->  NSMutableAttributedString {
        let textContent = text
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 22)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.18
        textString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: textRange)
        return textString
    }

    @objc func syncLayerButtonAction(sender: UIButton!) {
        // removes the sync view by removing the white screen view that contains the other views
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            whenSyncClosed()
        }
    }
}

extension BaseViewController {
    func sync(completion: @escaping (_ synced: Bool) -> Void) {
        self.beginSyncLoadingAnimation()
        self.hideSyncViewButton()
        APIManager.sync(completion: { (done) in
            if done {
                //                self.endSyncLoadingAnimation()
                self.successLoadingAnimation()
                self.endSyncLoadingAnimation()
                self.updateSyncDescription(text: "Sync completed.")
                self.showSyncViewButton()
                return completion(true)
            } else {
                self.updateSyncDescription(text: "Sync failed")
                self.updateSyncButtonTitle(text: "Close")
                self.endSyncLoadingAnimation()
                self.failLoadingAnimation()
                self.showSyncViewButton()
                return completion(true)
            }
            self.enableSyncViewButton()

        }) { (progress) in
            self.updateSyncDescription(text: progress)
            //            self.syncTitle.text = progress
        }
    }
}

// Mark: Authentication
extension BaseViewController {
    func authenticateIfRequred() {
        if !authServices.isAuthenticated() {
            let vc = authServices.viewController() { (credentials, error) in

                guard let _ = credentials, error == nil else {
                    let title = "Authentication"
                    let message = "Authentication didn't work. Please try again."

                    self.showAlert(with: title, message: message)

                    return
                }
                self.authenticated = true
                //                self.syncing = true
                //                self.beginSync()
                //                                self.confirmNetworkAvailabilityBeforUpload(handler: self.uploadHandler())
            }
            present(vc, animated: true, completion: nil)
        } else {
            authServices.refreshCredientials(completion: { (credentials: Credentials?, error: Error?) in

                if let error = error, error == AuthenticationError.expired {
                    let vc = self.authServices.viewController() { (credentials, error) in

                        guard let _ = credentials, error == nil else {
                            let title = "Authentication"
                            let message = "Authentication didn't work. Please try again."

                            self.showAlert(with: title, message: message)

                            return
                        }
                        self.authenticated = true
                    }

                    self.present(vc, animated: true, completion: nil)
                    return
                }
                //                self.syncing = true
                //                self.beginSync()
                self.authenticated = true
            })
        }
    }

}
