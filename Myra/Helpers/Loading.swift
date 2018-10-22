//
//  Loading.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-18.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Lottie


public class Loading {
    public static let shared = Loading()
    private init() {}

    let tag = 987

    func begin() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                // Create a view that fills the screen
                let view = UIView(frame: window.frame)
                view.tag = self.tag
                window.addSubview(view)

                // add anchors to center and rotate properly
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: window.frame.width),
                    view.heightAnchor.constraint(equalToConstant: window.frame.height),
                    view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                    view.topAnchor.constraint(equalTo: window.topAnchor),
                    view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: window.leftAnchor),
                    view.rightAnchor.constraint(equalTo: window.rightAnchor)
                    ])
                // add white background
                view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: 0.5)
view.topAnchor.constraint(equalTo: window.topAnchor)

                // add sync icon
                let animationView = LOTAnimationView(name: "spinner2_")
                animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                animationView.center.y = view.center.y
                animationView.center.x = view.center.x
                animationView.contentMode = .scaleAspectFit
                animationView.loopAnimation = true
                // add subview to white screen view
                view.addSubview(animationView)
                // add anchors to center and rotate properly
                animationView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    ])
                animationView.play()
            }
        }
    }

    func end() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let window = UIApplication.shared.keyWindow, let view = window.viewWithTag(self.tag) {
                view.removeFromSuperview()
            }
        }
    }
}
