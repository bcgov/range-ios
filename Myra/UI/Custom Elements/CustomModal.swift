//
//  CustomModal.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit


enum customModalContraint {
    case Width
    case Height
    case CenterX
    case CenterY
    case Bottom
}

class CustomModal: UIView, Theme {
    
    // MARK: Variables
    private var contraintsAdded: [customModalContraint: NSLayoutConstraint] = [customModalContraint: NSLayoutConstraint]()
    
    // Space between bottom of modal and keyboard, when keyboard covers modal
    private let keyboardPadding: CGFloat = 25
    
    private var width: CGFloat = 390
    private var height: CGFloat = 400
    private var verticalPadding: CGFloat = 0
    private var horizontalPadding: CGFloat = 0
    
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0
    private let fieldErrorAnimationDuration = 2.0
    
    // White screen
    private let whiteScreenTag: Int = 9532
    private let whiteScreenAlpha: CGFloat = 0.9
    
    // MARK: Class funcs
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            // UIView disappear
           removeKeyboardObserver()
        } else {
           addKeyboardObserver()
        }
    }
    
    // MARK: Keyboard handler
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotificationObserver(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotificationObserver(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func didReceiveKeyboardNotificationObserver(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo["UIKeyboardFrameEndUserInfoKey"] as? NSValue else {return}
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            addKeyboardContraints(keyboardFrame: keyboardFrame.cgRectValue)
            activateConstraints()
        case UIResponder.keyboardWillHideNotification:
            removeKeyboardConstraints()
            activateConstraints()
        default:
            break
        }
    }
    
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
    
    func setSmartSizingWith(percentHorizontalPadding: CGFloat, percentVerticalPadding: CGFloat) {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.horizontalPadding = self.get(percent: percentHorizontalPadding, of: window.frame.width)
        self.verticalPadding = self.get(percent: percentVerticalPadding, of: window.frame.height)
        
        // Choose a witdh or height that stay the same regardless of orientation.
        if window.frame.width > window.frame.height {
            // Horizontal
            self.height = window.frame.height - (verticalPadding)
            self.width = window.frame.height - (horizontalPadding)
        } else {
            // vertical
            self.height = window.frame.width - (verticalPadding)
            self.width = window.frame.width - (horizontalPadding)
        }
        
    }
    
    func get(percent: CGFloat, of: CGFloat)-> CGFloat {
        return ((of * percent) / 100)
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
    func hide() {
        remove()
    }
    
    func show() {
        present()
    }
    
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
        addInitialConstraints()
        activateConstraints()
        
        showWhiteBG(then: {
            self.openingAnimation {
                return then()
            }
        })
    }
    
    // MARK: Contraints
    func activateConstraints() {
        var addedConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        var removedConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        for each in contraintsAdded {
            if each.value.isActive == true {
                addedConstraints.append(each.value)
            } else {
                removedConstraints.append(each.value)
            }
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(addedConstraints)
        NSLayoutConstraint.deactivate(removedConstraints)
        self.layoutIfNeeded()
    }
    
    func addInitialConstraints() {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthContraint = self.widthAnchor.constraint(equalToConstant: width)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        let centerXContraint = self.centerXAnchor.constraint(equalTo: window.centerXAnchor)
        let centerYConstraint = self.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        
        widthContraint.isActive = true
        heightConstraint.isActive = true
        centerXContraint.isActive = true
        centerYConstraint.isActive = true
        
        self.contraintsAdded[.Width] = widthContraint
        self.contraintsAdded[.Height] = heightConstraint
        self.contraintsAdded[.CenterX] = centerXContraint
        self.contraintsAdded[.CenterY] = centerYConstraint
    }
    
    func addCenterConstraints() {
        guard let centerXIndex = contraintsAdded.index(forKey: .CenterX), let centerYIndex = contraintsAdded.index(forKey: .CenterY), let centerXContraint = contraintsAdded.at(centerXIndex), let centerYContraint = contraintsAdded.at(centerYIndex) else {
            return
        }
        centerYContraint.value.isActive = true
        centerXContraint.value.isActive = true
    }
    
    func removeCenterContraints() {
        guard let centerXIndex = contraintsAdded.index(forKey: .CenterX), let centerYIndex = contraintsAdded.index(forKey: .CenterY), let centerXContraint = contraintsAdded.at(centerXIndex), let centerYContraint = contraintsAdded.at(centerYIndex) else {
            return
        }
        centerYContraint.value.isActive = false
        centerXContraint.value.isActive = false
    }
    
    func addKeyboardContraints(keyboardFrame: CGRect) {
        if !isKeyboardCoveringMe(keyboardFrame: keyboardFrame) {return}
        guard let window = UIApplication.shared.keyWindow else {return}
 
        if let centerXIndex = contraintsAdded.index(forKey: .CenterX), let centerYIndex = contraintsAdded.index(forKey: .CenterY), let centerXContraint = contraintsAdded.at(centerXIndex), let centerYContraint = contraintsAdded.at(centerYIndex) {
            centerYContraint.value.isActive = false
            centerXContraint.value.isActive = true
            if let bottomIndex = contraintsAdded.index(forKey: .Bottom), let existingBottomContraint = contraintsAdded.at(bottomIndex) {
                existingBottomContraint.value.isActive = true
            } else {
                let bottomConstraint = self.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0 - (keyboardFrame.origin.y + keyboardPadding))
                bottomConstraint.isActive = true
                self.contraintsAdded[.Bottom] = bottomConstraint
            }
        }
    }
    
    func removeKeyboardConstraints() {
        guard let centerYIndex = contraintsAdded.index(forKey: .CenterY), let bottomIndex = contraintsAdded.index(forKey: .Bottom), let centerYContraint = contraintsAdded.at(centerYIndex), let bottomContraint = contraintsAdded.at(bottomIndex) else {
            return
        }
       
        bottomContraint.value.isActive = false
        centerYContraint.value.isActive = true
    }
    
    func isKeyboardCoveringMe(keyboardFrame: CGRect) -> Bool {
         guard let window = UIApplication.shared.keyWindow else {return false}
        let myEstimatedBottom = window.center.y + (self.height/2)
        if myEstimatedBottom > keyboardFrame.origin.y {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Displaying animations
    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }
    
    func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
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
        
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
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
            UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func recursivelyRemoveWhiteScreens(attempt: Bool) {
        if !attempt { return }
        var found = false
        if let window = UIApplication.shared.keyWindow, let viewWithTag = window.viewWithTag(whiteScreenTag) {
            found = true
            viewWithTag.removeFromSuperview()
        }
        recursivelyRemoveWhiteScreens(attempt: found)
    
    }
    
}
