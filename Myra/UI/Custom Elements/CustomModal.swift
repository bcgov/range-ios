//
//  CustomModal.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

class CustomModal: UIView, Theme {
    // MARK: Variables
    private var width: CGFloat = 390
    private var height: CGFloat = 400
    private var verticalPadding: CGFloat = 0
    private var horizontalPadding: CGFloat = 0
    
    private let animationDuration = 0.5
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0
    private let fieldErrorAnimationDuration = 2.0
    
    // White screen
    private let whiteScreenTag: Int = 9532
    private let whiteScreenAlpha: CGFloat = 0.9
    
    
    // MARK: Size
    func setFixed(width: CGFloat, height: CGFloat) {
        self.height = height
        self.width = width
    }
    
    func setSmartSizingWith(horizontalPadding: CGFloat, verticalPadding: CGFloat) {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        
        // Choose a witdh or height that stay the same regardless of orientation.
        if window.frame.width > window.frame.height {
            // Horizontal
            self.height = window.frame.height - (verticalPadding * 2)
            self.width = window.frame.height - (horizontalPadding * 2)
        } else {
            // vertical
            self.height = window.frame.width - (verticalPadding * 2)
            self.width = window.frame.width - (horizontalPadding * 2)
        }
    }
    
    // MARK: Style
    func styleModalBox(with titleLabel: UILabel? = nil, barButton: UIButton? = nil, closeButton: UIButton? = nil) {
        addShadow(layer: self.layer)
        styleContainer(view: self)
        if let titleLabel = titleLabel {
            titleLabel.font = Fonts.getPrimaryBold(size: 22)
            titleLabel.textColor = Colors.active.blue
        }
        
        if let barButton = barButton {
            barButton.setTitleColor(Colors.active.blue, for: .normal)
        }
        
        if let closeButton = closeButton {
            guard let image = UIImage(named: "Close") else {return}
            closeButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            closeButton.setTitle("", for: .normal)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 25),
                closeButton.heightAnchor.constraint(equalToConstant: 25),
                ])
        }
    }
    
    // MARK: Positioning/ displaying
    func remove() {
        self.closingAnimation {
            self.removeWhiteScreen()
            self.removeFromSuperview()
        }
    }
    
    func present() {
        guard let window = UIApplication.shared.keyWindow else {return}
        window.isUserInteractionEnabled = false
        position {
            window.isUserInteractionEnabled = true
        }
    }
    
    func position(then: @escaping ()-> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.alpha = 0
        window.addSubview(self)
        addConstraints()
        
        showWhiteBG(then: {
            self.openingAnimation {
                return then()
            }
        })
    }
    
    func addConstraints() {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        let widthContraint =  self.widthAnchor.constraint(equalToConstant: width)
        let heightContraint = self.heightAnchor.constraint(equalToConstant: height)
        let centerXContraint = self.centerXAnchor.constraint(equalTo: window.centerXAnchor)
        let centerYContraint = self.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        NSLayoutConstraint.activate([ widthContraint, heightContraint, centerXContraint, centerYContraint, ])
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
    
    // MARK: White Screen
    func showWhiteBG(then: @escaping()-> Void) {
        guard let window = UIApplication.shared.keyWindow, let bg = whiteScreen() else {return}
        
        bg.alpha = invisibleAlpha
        window.insertSubview(bg, belowSubview: self)
        bg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.centerXAnchor.constraint(equalTo:  window.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo:  window.centerYAnchor),
            bg.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            bg.topAnchor.constraint(equalTo: window.topAnchor),
            bg.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        
        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
        }) { (done) in
            return then()
        }
        
    }
    
    func whiteScreen() -> UIView? {
        guard let window = UIApplication.shared.keyWindow else {return nil}
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height))
        view.center.y = window.center.y
        view.center.x = window.center.x
        view.backgroundColor = Colors.active.blue.withAlphaComponent(0.2)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }
    
    func removeWhiteScreen() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let viewWithTag = window.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
}
