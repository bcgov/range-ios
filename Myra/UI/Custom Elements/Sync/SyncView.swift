//
//  SyncView.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Lottie

class SyncView: CustomModal {

    // MARK: Constants
    let syncIconTag = 200
    let animationDuration = 0.5
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    let whiteScreenAlpha: CGFloat = 0.9
    let successIconSizeIncrease: CGFloat = 80

    // MARK: Variables
    var callBack: ((_ success: Bool) -> Void )?
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
    func initialize(completion: @escaping (_ success: Bool) -> Void) {
        AutoSync.shared.endListener()
        self.callBack = completion
        setFixed(width: 390, height: 400)
        style()
        present()
        self.styleSyncInProgress()
        API.sync(completion: { (successful) in
            self.succcess = successful
            if successful {
                self.styleSyncSuccess()
            } else {
                self.styleSyncFail(error: "An error has occurred")
            }
        }, progress: { (progress) in
            self.updateSyncDescription(text: progress)
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
        styleModalBox()
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
}
