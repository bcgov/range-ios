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
    let inputViewContainerTag = 201

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
    // TODO: Remove
    var loadingImages = [UIImage]()
    var currentPopOver: UIViewController?
    var presenterVC: UIViewController?

    // NARK: VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Remove
        if loadingImages.count != 4 {
            setupLoadingIndicatorImages()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Feedback.initializeButton()
    }

    // MARK: Event handlers
    func onAuthenticationFail() {}
    func onAuthenticationSuccess() {}
    func whenSyncClosed() {}
    func whenLandscape() {}
    func whenPortrait() {}
    func syncEnd() {}
    func orientationChanged() {
        dismissPopOver()
    }

    // MARK:
    func setPresenter(viewController: UIViewController) {
        self.presenterVC = viewController
    }

    func getPresenter() -> MainViewController? {
        guard let presenter = self.presenterVC, let mainVC = presenter as? MainViewController else {return nil}
        return mainVC
    }

    // MARK: Utilities
    public func dismissKeyboard() {
        self.view.endEditing(true)
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
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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

    // MARK: Input container
    func getInputViewContainer() -> UIView {
        // white screen
        let layerWidth: CGFloat = 330
        let layerHeight: CGFloat = 150
        let layer = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: layerWidth, height: layerHeight))
        layer.layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white
        layer.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 10
        layer.center.x = self.view.center.x
        layer.center.y = self.view.center.y
        layer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        layer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        layer.tag = inputViewContainerTag
        return layer
    }

    // MARK: Popover
    func showPopOver(on: UIButton, vc: UIViewController, height: Int, width: Int, arrowColor: UIColor?) {
        self.view.endEditing(true)
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: width, height: height)
        guard let popover = vc.popoverPresentationController else {return}
        popover.backgroundColor = arrowColor ?? UIColor.white
        popover.permittedArrowDirections = .any
        popover.sourceView = on
        popover.sourceRect = CGRect(x: on.bounds.midX, y: on.bounds.midY, width: 0, height: 0)
        self.currentPopOver = vc
        present(vc, animated: true, completion: nil)
    }

    func showPopOver(on: CALayer, inView: UIView, vc: UIViewController, height: Int, width: Int, arrowColor: UIColor?) {
        self.view.endEditing(true)
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: width, height: height)
        guard let popover = vc.popoverPresentationController else {return}
        popover.backgroundColor = arrowColor ?? UIColor.white
        popover.permittedArrowDirections = .any
        popover.sourceView = inView
        popover.sourceRect = CGRect(x: on.frame.midX, y: on.frame.midY, width: 0, height: 0)
        self.currentPopOver = vc
        present(vc, animated: true, completion: nil)
    }

    func showTooltip(on: UIButton, title: String, desc: String) {
        let vm = ViewManager()
        let tooltip = vm.tooltip
        tooltip.setup(title: title, desc: desc)
        let defaultWidth = 500
        let spacing = 8
        let iconWidth = 25 + (spacing * 2)
        let padding: CGFloat = 50
        let titleHeight: CGFloat = 25
        let descHeight = desc.height(withConstrainedWidth: CGFloat(defaultWidth - iconWidth - spacing), font: toolTipDescriptionFont())
        let contentHeight = Int(titleHeight + descHeight + padding)
        showPopOver(on: on, vc: tooltip, height: contentHeight, width: defaultWidth, arrowColor: Colors.active.blue)
    }

    // dismisses the last popover added
    func dismissPopOver() {
        if let popOver = self.currentPopOver {
            popOver.dismiss(animated: false, completion: nil)
        }
    }

    // dismisses the specified vc
    func hidepopup(vc: SelectionPopUpViewController) {
        vc.dismiss(animated: true, completion: nil)
        return
    }

    // wrapper for showPopOver()
    func showPopUp(vc: SelectionPopUpViewController, on: UIButton) {
        let popOverWidth = vc.getEstimatedWidth()
        var popOverHeight = 300
        if vc.canDisplayFullContentIn(height: popOverHeight) {
            popOverHeight =  vc.getEstimatedHeight()
        }
        showPopOver(on: on, vc: vc, height: popOverHeight, width: popOverWidth, arrowColor: nil)
    }

    func showPopUp(vc: SelectionPopUpViewController, on: CALayer, inView: UIView) {
        let popOverWidth = vc.getEstimatedWidth()
        var popOverHeight = 300
        if vc.canDisplayFullContentIn(height: popOverHeight) {
            popOverHeight =  vc.getEstimatedHeight()
        }
        showPopOver(on: on, inView: inView, vc: vc, height: popOverHeight, width: popOverWidth, arrowColor: nil)
    }
}

// MARK: Custom messages
extension BaseViewController {
    func fadeLabelMessage(label: UILabel, text: String) {
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 0
            self.view.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = text
            // fade in warning text
            UIView.animate(withDuration: 0.2, animations: {
                label.textColor = Colors.accent.red
                label.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: 0.2, delay: 3, animations: {
                    // fade out text
                    label.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: 0.2, animations: {
                        label.textColor = originalTextColor
                        label.alpha = 1
                        self.view.layoutIfNeeded()
                    })
                })
            })
        }
    }
}

// MARK: Loading Spinner
extension BaseViewController {
    // TODO: Remove
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
            if size.width > size.height {
                self.whenLandscape()
            } else {
                self.whenPortrait()
            }
//            if UIDevice.current.orientation.isLandscape{
//                self.whenLandscape()
//            } else if UIDevice.current.orientation.isPortrait {
//                self.whenPortrait()
//            } else {
//                self.whenLandscape()
//            }
        }
    }
}

// MARK: Alerts
extension BaseViewController {
    
    func alert(with title: String, message: String) {
        Alert.show(title: title, message: message)
    }

    func showAlert(title: String, description: String, yesButtonTapped:@escaping () -> (), noButtonTapped:@escaping () -> ()) {
        Alert.show(title: title, message: description, yes: {
            yesButtonTapped()
        }) {
            noButtonTapped()
        }
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

extension BaseViewController {
    func sync(completion: @escaping (_ synced: Bool) -> Void) {
        let syncView: SyncView = UIView.fromNib()
        syncView.begin(in: self) { success in
            return completion(success)
        }
    }
}

// MARK: Authentication
extension BaseViewController {
    func authenticateIfRequred(sender: UIButton? = nil) {
        if !authServices.isAuthenticated() {
            let vc = authServices.viewController() { (credentials, error) in

                guard let _ = credentials, error == nil else {
                    let title = "Authentication"
                    let message = "Authentication didn't work. Please try again."

                    self.alert(with: title, message: message)
                    if let senderButton = sender {
                        senderButton.isUserInteractionEnabled = true
                    }
                    self.onAuthenticationFail()
                    return
                }
                self.onAuthenticationSuccess()
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

                            self.alert(with: title, message: message)
                            if let senderButton = sender {
                                senderButton.isUserInteractionEnabled = true
                            }
                            self.onAuthenticationFail()
                            return
                        }
                        self.onAuthenticationSuccess()
                    }

                    self.present(vc, animated: true, completion: nil)
                    return
                }
                self.onAuthenticationSuccess()
            })
        }
    }

    func logout() {
        authServices.logout()
        RealmManager.shared.clearLastSyncDate()
        RealmManager.shared.clearAllData()
    }

}
