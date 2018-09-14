//
//  SyncView.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Lottie

class SyncView: UIView, Theme {

    // MARK: Constants
    let syncIconTag = 200
    let whiteScreenTag = 201
    let animationDuration = 0.5
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    let whiteScreenAlpha: CGFloat = 0.9
    let successIconSizeIncrease: CGFloat = 80

    // MARK: Variables
    var callBack: ((_ success: Bool) -> Void )?
    var parent: UIViewController?
    var succcess: Bool = false

    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var syncMessage: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var syncIconContainer: UIView!

    // MARK: Outlet actions
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let callBack = self.callBack else {return}
        self.removeWhiteScreen()
        closingAnimation {
            AutoSync.shared.beginListener()
            self.removeFromSuperview()
            return callBack(self.succcess)
        }
    }

    // MARK: Setup
    func begin(in vc: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        AutoSync.shared.endListener()
        self.parent = vc
        self.callBack = completion
        style()
        self.alpha = invisibleAlpha
        position(then: {
            self.styleSyncInProgress()
            APIManager.sync(completion: { (error: APIError?) in
                if let error = error {
                    self.styleSyncFail(error: "\(error.localizedDescription)")
                    self.succcess = false
                } else {
                    self.succcess = true
                    self.styleSyncSuccess()
                }
            }) { (progress) in
                self.updateSyncDescription(text: progress)
            }
        })
    }

    // MARK: Label text updates
    func updateSyncDescription(text: String) {
        DispatchQueue.main.async {
            self.syncMessage.text = text
        }
    }

    func updateSyncTitle(text: String) {
        DispatchQueue.main.async {
            self.title.text = text
        }
    }

    // MARK: Styles
    func style() {
        styleHollowButton(button: button)
        addSyncIcon()
        addShadow(layer: self.layer)
        divider.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        title.font = Fonts.getPrimaryBold(size: 22)
        title.textColor = Colors.active.blue
        syncMessage.font = Fonts.getPrimaryMedium(size: 17)
        syncMessage.textColor = Colors.technical.mainText
        self.button.alpha = invisibleAlpha
        self.title.text = ""
        self.syncMessage.text = ""
    }

    func styleSyncInProgress() {
        animateSyncIcon()
        title.text = "Sync Changes"
        syncMessage.text = "Now syncing your data…"
        button.alpha = invisibleAlpha
        showSyncInProgressAnimation()
    }

    func styleSyncSuccess() {
        stopSyncIconAnimation()
        title.text = "Sync Changes"
        updateSyncDescription(text: "Sync Complete")
        syncMessage.text = "Sync Complete"
        button.setTitle("Close", for: .normal)
        styleFillButton(button: button)
        button.alpha = visibleAlpha
        showSyncCompletedAnimation()
    }

    func styleSyncFail(error: String) {
        stopSyncIconAnimation()
        title.text = "Sync Failed"
        syncMessage.text = error
        button.setTitle("Close", for: .normal)
        styleHollowButton(button: button)
        button.alpha = visibleAlpha
        showSyncFailedAnimation()
    }

    // MARK: Positioning/ displaying
    func position(then: @escaping ()-> Void) {
        guard let vc = self.parent else {return}
        self.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        self.center.x = vc.view.center.x
        self.center.y = vc.view.center.y
        self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        self.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(self)
        
        // Add constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 390),
            self.heightAnchor.constraint(equalToConstant: 400),
            self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        // White screen
        let bg = whiteScreen(for: vc)
        bg.alpha = invisibleAlpha
        vc.view.insertSubview(bg, belowSubview: self)
        NSLayoutConstraint.activate([
            bg.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
            bg.heightAnchor.constraint(equalTo:  vc.view.heightAnchor),
            bg.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
            self.openingAnimation {
                return then()
            }
        })
    }

    // MARK: Displaying animations
    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }

    func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.invisibleAlpha
        }) { (done) in
            then()
        }
    }

    // MARK: Lottie
    func animateSyncIcon() {
        if let animation = self.viewWithTag(syncIconTag) as? LOTAnimationView {
            animation.alpha = visibleAlpha
            animation.loopAnimation = true
            animation.play()
        }
    }

    func stopSyncIconAnimation() {
        if let animation = self.viewWithTag(syncIconTag) as? LOTAnimationView {
            animation.loopAnimation = false
            animation.stop()
        }
    }

    func addSyncIcon() {
        let animatedSync = LOTAnimationView(name: "sync_icon")
        animatedSync.frame = syncIconContainer.frame
        animatedSync.center.y = syncIconContainer.center.y
        animatedSync.center.x = syncIconContainer.center.x
        animatedSync.contentMode = .scaleAspectFit
        animatedSync.loopAnimation = false
        animatedSync.tag = syncIconTag
        syncIconContainer.addSubview(animatedSync)

        // Add constraints
        animatedSync.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedSync.widthAnchor.constraint(equalToConstant: syncIconContainer.frame.width),
            animatedSync.heightAnchor.constraint(equalToConstant: syncIconContainer.frame.height),
            animatedSync.centerXAnchor.constraint(equalTo: syncIconContainer.centerXAnchor),
            animatedSync.centerYAnchor.constraint(equalTo: syncIconContainer.centerYAnchor),
        ])
        animatedSync.alpha = invisibleAlpha
    }

    func clearIcon() {
        for subview in iconContainer.subviews {
            subview.alpha = invisibleAlpha
            subview.removeFromSuperview()
        }
    }

    func showSyncInProgressAnimation() {
        clearIcon()
        let animationView = LOTAnimationView(name: "spinner2_")
        animationView.frame = iconContainer.frame
        animationView.center.y = iconContainer.center.y
        animationView.center.x = iconContainer.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.alpha = visibleAlpha
        iconContainer.addSubview(animationView)

        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: iconContainer.frame.width),
            animationView.heightAnchor.constraint(equalToConstant: iconContainer.frame.height),
            animationView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ])
        animationView.play()
    }

    func showSyncCompletedAnimation() {
        clearIcon()
        let animationView = LOTAnimationView(name: "checked_done_")
        animationView.frame = iconContainer.frame
        animationView.center.y = iconContainer.center.y
        animationView.center.x = iconContainer.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = false
        animationView.alpha = visibleAlpha
        iconContainer.addSubview(animationView)

        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: iconContainer.frame.width + successIconSizeIncrease),
            animationView.heightAnchor.constraint(equalToConstant: iconContainer.frame.height + successIconSizeIncrease),
            animationView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ])
        animationView.play()
    }

    func showSyncFailedAnimation() {
        clearIcon()
        let animationView = LOTAnimationView(name: "x_pop")
        animationView.frame = iconContainer.frame
        animationView.center.y = iconContainer.center.y
        animationView.center.x = iconContainer.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = false
        animationView.alpha = visibleAlpha
        iconContainer.addSubview(animationView)

        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: iconContainer.frame.width),
            animationView.heightAnchor.constraint(equalToConstant: iconContainer.frame.height),
            animationView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ])
        animationView.play()
    }

    // MARK: White Screen
    func whiteScreen(for vc: UIViewController) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height))
        view.center.y = vc.view.center.y
        view.center.x = vc.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: whiteScreenAlpha)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let parent = parent else {return}
        if let viewWithTag = parent.view.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }
}
