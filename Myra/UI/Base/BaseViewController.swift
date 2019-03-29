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
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    
    // MARK: Variables
    var navigationTitle: String?
    var currentPopOver: UIViewController?
    var presenterVC: UIViewController?
    
    // MARK: VC Functions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Feedback.initializeButton()
        guard let presenter = self.getPresenter() else {return}
        presenter.setNav(title: navigationTitle ?? "")
    }
    
    // MARK: Event handlers
    func whenLandscape() {}
    func whenPortrait() {}
    func orientationChanged() {}
    
    // MARK: Utilities
    func setPresenter(viewController: UIViewController) {
        self.presenterVC = viewController
    }
    
    func getPresenter() -> MainViewController? {
        guard let presenter = self.presenterVC, let mainVC = presenter as? MainViewController else {return nil}
        return mainVC
    }
    
    public func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Sync
    func sync(completion: @escaping (_ synced: Bool) -> Void) {
        let syncView: SyncView = UIView.fromNib()
        syncView.initialize { (success) in
            SettingsManager.shared.refreshAuthIdpHintIfNecessary(completion: { (ApplicationVersionStatus) in
                if ApplicationVersionStatus == .isOld {
                    Alert.show(title: "New Version Available", message: "A newer version of MyRangeBC is available.\nPlease Synchronize data before updating the application.")
                }
                return completion(success)
            })
        }
    }
    
    // MARK: Tooltips
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
    
    // MARK: Animations
    func animateIt() {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func animateFor(time: Double) {
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Custom messages
    func fadeLabelMessage(label: UILabel, text: String) {
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            label.alpha = self.invisibleAlpha
            self.view.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = text
            // fade in warning text
            UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
                label.textColor = Colors.accent.red
                label.alpha = self.visibleAlpha
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), delay: 3, animations: {
                    // fade out text
                    label.alpha = self.invisibleAlpha
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
                        label.textColor = originalTextColor
                        label.alpha = self.visibleAlpha
                        self.view.layoutIfNeeded()
                    })
                })
            })
        }
    }
    
    // MARK: Statusbar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Screen Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.dismissPopOver()
            self.notifyOrientationChange()
            if size.width > size.height {
                self.whenLandscape()
            } else {
                self.whenPortrait()
            }
        }
    }
    
    func notifyOrientationChange() {
        orientationChanged()
        NotificationCenter.default.post(name: .screenOrientationChanged, object: nil)
    }
    
    // MARK: Alerts
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
