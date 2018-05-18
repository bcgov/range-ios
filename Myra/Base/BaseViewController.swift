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

class BaseViewController: UIViewController, Theme {

    // MARK: Constants
    let mediumAnimationDuration = 0.5
    let shortAnimationDuration = 0.3
    let whiteScreenTag = 100

    // MARK: Sync Screen constants
    let syncTitleTag = 101
    let syncDescriptionTag = 102
    let syncButtonTag = 103
    let syncContainerTag = 104
    let syncLoadingAnimationTag = 105
    let syncSuccessAnimationTag = 106
    let syncFailAnimationTag = 107
    let loadingAnimationTag = 110

    // MARK: Auth constants
    let authServices: AuthServices = {
        return AuthServices(baseUrl: Constants.SSO.baseUrl, redirectUri: Constants.SSO.redirectUri,
                            clientId: Constants.SSO.clientId, realm: Constants.SSO.realmName,
                            idpHint: Constants.SSO.idpHint)
    }()

    // MARK: Variables
    var loading: UIImageView?
    var loadingImages = [UIImage]()

    var authenticated: Bool = false {
        didSet{
            if authenticated {
                whenAuthenticated()
            }
        }
    }

    var currentPopOver: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if loadingImages.count != 4 {
            setupLoadingIndicatorImages()
        }
    }

    // MARK: Event handlers
    func whenSyncClosed() {}
    func whenAuthenticated() {}
    func whenLandscape() {}
    func whenPortrait() {}
    func orientationChanged() {
        dismissPopOver()
    }

    func notifyOrientationChange() {
        orientationChanged()
        NotificationCenter.default.post(name: .screenOrientationChanged, object: nil)
    }

    // Mark: White screen for popups
    func getWhiteScreen() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.9)
        view.alpha = 1
        view.tag = whiteScreenTag
        return view
    }

    func showWhiteScreen() {
        self.view.addSubview(getWhiteScreen())
    }

    func removeWhiteScreen() {
        if let whiteView = self.view.viewWithTag(whiteScreenTag) {
            whiteView.removeFromSuperview()
        }
    }

    func styleInput(input: UITextField) {
        input.layer.cornerRadius = 3
        input.layer.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1).cgColor
    }

    // MARK: Popover
    func showPopOver(on: UIButton, vc: UIViewController, height: Int, width: Int, arrowColor: UIColor?) {
        self.view.endEditing(true)
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: width, height: height)
        let popover = vc.popoverPresentationController
        popover?.backgroundColor = arrowColor ?? UIColor.white
        popover?.permittedArrowDirections = .any
        popover?.sourceView = on
        popover?.sourceRect = CGRect(x: on.bounds.midX, y: on.bounds.midY, width: 0, height: 0)
        self.currentPopOver = vc
        present(vc, animated: true, completion: nil)
    }

    func dismissPopOver() {
        if let popOver = self.currentPopOver {
            popOver.dismiss(animated: false, completion: nil)
        }
    }

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

// MARK: Loading Spinner
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
        view.tag = loadingAnimationTag
        return view
    }

    func beginLoading() {
        loading = getIoadingView()
        self.view.addSubview(loading!)
        loading?.startAnimating()
    }

    func endLoading() {
        if let imageView = self.view.viewWithTag(loadingAnimationTag) {
            imageView.removeFromSuperview()
        }
    }

    // MARK: Screen Rotation
    // TODO: reposition loading spinner.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.notifyOrientationChange()
            self.rotateSync()
            if UIDevice.current.orientation.isLandscape{
                self.whenLandscape()
            } else if UIDevice.current.orientation.isPortrait {
                self.whenPortrait()
            } else {
                self.whenLandscape()
            }
        }
    }
}

// MARK: Alerts
extension BaseViewController {
    
    func showAlert(with title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        ac.addAction(cancel)

        present(ac, animated: true, completion: nil)
    }
    
    func showAlert(title: String, description: String, yesButtonTapped:@escaping () -> (), noButtonTapped:@escaping () -> ()) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                yesButtonTapped()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                noButtonTapped()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Animations
extension BaseViewController {
    func animateIt() {
        UIView.animate(withDuration: shortAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func animateFor(time: Double) {
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: Status Bar Appearance
extension BaseViewController {
    func setStatusBarAppearanceLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    func setStatusBarAppearanceDark() {
        UIApplication.shared.statusBarStyle = .default
    }
}

// MARK: Sync view
extension BaseViewController {

    func getSyncView() -> UIView {

        // white screen
        let view = getWhiteScreen()

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
        layer.tag = syncContainerTag

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

        textLayer.tag = syncTitleTag
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
        descLayer.numberOfLines = 2
        descLayer.textColor = UIColor.black
        descLayer.attributedText = getSycDescriptionText(text: "")
        descLayer.textAlignment = .center

        descLayer.tag = syncDescriptionTag
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

        button.tag = syncButtonTag
        // add to layer that holds content
        layer.addSubview(button)

        let spinnerWidth: CGFloat = 200
        let animationView = LOTAnimationView(name: "spinner_")
        animationView.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.tag = syncLoadingAnimationTag
        animationView.alpha = 0
        layer.addSubview(animationView)

        let animationView2 = LOTAnimationView(name: "checked_done_")
        animationView2.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView2.contentMode = .scaleAspectFit
        animationView2.loopAnimation = false
        animationView2 .tag = syncSuccessAnimationTag
        animationView2.alpha = 0
        layer.addSubview(animationView2)

        let animationView3 = LOTAnimationView(name: "x_pop")
        animationView3.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        animationView3.contentMode = .scaleAspectFit
        animationView3.loopAnimation = false
        animationView3.tag = syncFailAnimationTag
        animationView3.alpha = 0
        layer.addSubview(animationView3)

        // add layer that holds content to gray screen
        view.addSubview(layer)

        // give the view that contains it all (white screen)
        view.tag = whiteScreenTag

        return view
    }

    func beginSyncLoadingAnimation() {
        if let animationView = self.view.viewWithTag(syncLoadingAnimationTag) as? LOTAnimationView {
            animationView.alpha = 1
            animationView.play()
        }
    }

    func endSyncLoadingAnimation() {
        if let loadingView = self.view.viewWithTag(syncLoadingAnimationTag) as? LOTAnimationView {
            loadingView.alpha = 0
        }
    }

    func successLoadingAnimation() {
        if let done = self.view.viewWithTag(syncSuccessAnimationTag) as? LOTAnimationView {
            done.play()
            done.alpha = 1
        }
    }

    func failLoadingAnimation() {
        if let err = self.view.viewWithTag(syncFailAnimationTag) as? LOTAnimationView {
            err.alpha = 1
            err.play()
        }
    }

    func updateSyncDescription(text: String) {
        if let viewWithTag = self.view.viewWithTag(syncDescriptionTag) as? UILabel {
            viewWithTag.attributedText = getSycDescriptionText(text: text)
            viewWithTag.textAlignment = .center
        }
    }

    func updateSyncTitle(text: String) {
        if let label = self.view.viewWithTag(syncTitleTag) as? UILabel {
            label.attributedText = getSycnTitleText(text: text)
        }
    }

    func updateSyncButtonTitle(text: String) {
        if let button = self.view.viewWithTag(syncButtonTag) as? UIButton {
            button.setTitle(text, for: .normal)
        }
    }

    func disableSyncViewButton() {
        if let button = self.view.viewWithTag(syncButtonTag) as? UIButton {
            button.isEnabled = false
        }
    }

    func enableSyncViewButton() {
        if let button = self.view.viewWithTag(syncButtonTag) as? UIButton {
            button.isEnabled = true
        }
    }

    func showSyncViewButton() {
        if let button = self.view.viewWithTag(syncButtonTag) as? UIButton {
            button.alpha = 1
        }
    }

    func hideSyncViewButton() {
        if let button = self.view.viewWithTag(syncButtonTag) as? UIButton {
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

    func rotateSync() {
        if let whiteBG = self.view.viewWithTag(whiteScreenTag), let container = self.view.viewWithTag(syncContainerTag) {
            whiteBG.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            whiteBG.center.y = self.view.center.y
            whiteBG.center.x = self.view.center.x

            let containerWidth: CGFloat = 400
            let containerHeight: CGFloat = 390

            container.frame.size.width = containerWidth
            container.frame.size.height = containerHeight
            container.center.y = self.view.center.y
            container.center.x = self.view.center.x
        }
    }

    @objc func syncLayerButtonAction(sender: UIButton!) {
        // removes the sync view by removing the white screen view that contains the other views
        if let viewWithTag = self.view.viewWithTag(whiteScreenTag) {
            viewWithTag.removeFromSuperview()
            whenSyncClosed()
        }
    }
}

extension BaseViewController {
    func sync(completion: @escaping (_ synced: Bool) -> Void) {
        self.beginSyncLoadingAnimation()
        self.hideSyncViewButton()
        APIManager.sync(completion: { (error: APIError?) in
            if let error = error {
                self.updateSyncDescription(text: "Sync Failed: \(error.localizedDescription)")
                self.updateSyncButtonTitle(text: "Close")
                self.endSyncLoadingAnimation()
                self.failLoadingAnimation()
                self.showSyncViewButton()
                self.enableSyncViewButton()
                return completion(true)
            } else {
                // self.endSyncLoadingAnimation()
                self.successLoadingAnimation()
                self.endSyncLoadingAnimation()
                self.updateSyncDescription(text: "Sync Completed.")
                self.showSyncViewButton()
                self.enableSyncViewButton()
                return completion(true)
            }
        }) { (progress) in
            self.updateSyncDescription(text: progress)
            //            self.syncTitle.text = progress
        }
    }
}

// MARK: Authentication
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
                if let error = error as? AuthenticationError, case .expired = error {
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

                
                self.authenticated = true
            })
        }
    }

    func logout() {
        authServices.logout()
        RealmManager.shared.clearLastSyncDate()
        RealmManager.shared.clearAllData()
    }

}
