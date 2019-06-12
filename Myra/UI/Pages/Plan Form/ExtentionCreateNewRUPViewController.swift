//
//  ExtentionCreateNewRUPViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

// This extention has all the styling for create page.
extension CreateNewRUPViewController {

    // MARK: Styles
    func style() {
        styleNavBar(title: viewTitle, navBar: headerContainer, statusBar: statusbar, primaryButton: saveToDraftButton, secondaryButton: nil, textLabel: ranLabel)
        if let cancelBtn = cancelButton {
            StyleNavBarButton(button: cancelBtn)
        }
        initMenu()

        switch mode {
        case .View:
            self.viewTitle.text = "View Plan"
            self.saveToDraftButton.setTitle("Close", for: .normal)
            self.ranLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 10).isActive = true
            if let cancelButton = self.cancelButton {
                 cancelButton.removeFromSuperview()
            }
        case .Edit:
            self.viewTitle.text = "Create New RUP"
            self.saveToDraftButton.setTitle("Save", for: .normal)
        }
    }

    func styleStatus() {
        styleNavBarLabel(label: statusAndagreementHolderLabel)
        makeCircle(view: statusLight)
        guard let plan = self.rup else {return}
        self.statusLight.backgroundColor = StatusHelper.getColor(for: plan)
    }

    // MARK: Side Menu
    func setMenuSize() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, let first = indexPath.first {
            self.tableView.scrollToRow(at: first, at: .top, animated: true)
        }
        
        if let menuView = self.menuView {
            menuView.setMenu(expanded: self.view.frame.width > self.view.frame.height)
        }

        self.animateIt()
    }

    func initMenu() {
        let menuXib: FormMenu = UIView.fromNib()
        menuXib.initialize(inView: menuContainer, containerWidth: menuWidth, parentTable: self.tableView, formMode: self.mode, onSubmit: {
            self.submitAction()
        })
        self.menuView = menuXib
    }

    // MARK: Submit Button
    func setSubmitButton(valid: Bool) {
        if let menuView = self.menuView {
            menuView.styleSubmitButton(valid: valid)
        }
    }
    
    // MARK: Animations
    func prepareToAnimate() {
        self.menuContainer.alpha = 0
        self.headerHeight.constant = 0
        self.menuWidth.constant = 0
        self.hideHeaderContent()
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
    }

    func hideHeaderContent() {
        self.ranLabel.alpha = 0
        self.statusAndagreementHolderLabel.alpha = 0
        self.statusLight.alpha = 0
        self.saveToDraftButton.alpha = 0
        self.viewTitle.alpha = 0
    }

    func showHeaderContent() {
        self.ranLabel.alpha = 1
        self.statusAndagreementHolderLabel.alpha = 1
        self.statusLight.alpha = 1
        self.saveToDraftButton.alpha = 1
        self.viewTitle.alpha = 1
    }

    func openingAnimations(callBack: @escaping ()->Void) {
        let defaultHeaderHeight: CGFloat = 60
        let showHeaderContentDelay = 0.2

        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), delay: showHeaderContentDelay, animations: {
            self.showHeaderContent()
            self.view.layoutIfNeeded()
        })

        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.headerHeight.constant = defaultHeaderHeight
            self.view.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {

                if UIDevice.current.orientation.isLandscape {
                    self.menuWidth.constant = self.landscapeMenuWidh
                } else if UIDevice.current.orientation.isPortrait {
                    self.menuWidth.constant = self.portraitMenuWidth
                } else {
                    self.menuWidth.constant = self.landscapeMenuWidh
                }
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
                    self.menuContainer.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    // MARK: End of opening animations
                    self.view.isUserInteractionEnabled = true
                    return callBack()
                })
            })
        }
    }

    func closingAnimations() {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.menuWidth.constant = 0
            self.menuContainer.alpha = 0
            self.view.layoutIfNeeded()
        })

        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.hideHeaderContent()
            self.headerHeight.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}
