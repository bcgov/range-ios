//
//  Loading.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-11.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Lottie

class Loading {
    static let shared = Loading()
    private init() {}

    private let loadingIconName: String = "spinner2_"
    private let tag: Int = 96
    private let width: CGFloat = 70
    private let height: CGFloat = 70

    // White screen
    private let whiteScreenTag: Int = 95
    private let whiteScreenAlpha: CGFloat = 0.8

    private func background(work: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            work()
        }
    }

    private func main(work: @escaping () -> ()) {
        DispatchQueue.main.async {
            work()
        }
    }

    // Add loading indiator and a background view
    func start() {
        Loading.shared.stop()
        if let window = UIApplication.shared.keyWindow {
            addWhiteScreen()
            let animationView = LOTAnimationView(name: self.loadingIconName)
            animationView.tag = tag

            // Position Icon
            let iconFrame = CGRect(x: (window.center.x - (self.width / 2)), y: (window.center.x - (self.height / 2)), width: self.width, height: self.height)

            animationView.frame = iconFrame
            animationView.center.y = window.center.y
            animationView.center.x = window.center.x
            animationView.contentMode = .scaleAspectFit
            animationView.loopAnimation = true
            window.addSubview(animationView)

            // Add constraints
            animationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalToConstant: self.width),
                animationView.heightAnchor.constraint(equalToConstant: self.height),
                animationView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                ])

            animationView.play()
        }
    }

    // remove loading indicator and its background
    func stop() {
        if let window = UIApplication.shared.keyWindow, let icon = window.viewWithTag(self.tag) as? LOTAnimationView  {
            icon.removeFromSuperview()
            removeWhiteScreen()
        }
    }

    // MARK: White Screen
    private func addWhiteScreen() {
        if let window = UIApplication.shared.keyWindow {
            let view = UIView(frame: window.frame)
            view.tag = self.whiteScreenTag
            view.center.x = window.center.x
            view.center.y = window.center.y
            view.backgroundColor = Colors.active.blue.withAlphaComponent(0.2)
            view.alpha = whiteScreenAlpha

            window.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: window.frame.width),
                view.heightAnchor.constraint(equalToConstant: window.frame.height),
                view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                ])
        }
    }

    private func removeWhiteScreen() {
        if let window = UIApplication.shared.keyWindow, let view = window.viewWithTag(self.whiteScreenTag) {
            view.removeFromSuperview()
        }
    }

}
