//
//  ExtentionCreateNewRUPViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit


extension CreateNewRUPViewController {
    // MARK: Styles
    func style() {
        styleHeader()
        styleMenu()
    }

    func setMenuSize() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
        }
        if UIDevice.current.orientation.isLandscape{
            self.menuWidth.constant = self.landscapeMenuWidh
        } else {
            self.menuWidth.constant = self.horizontalMenuWidth
        }
        self.animateIt()

    }

    func styleHeader() {
        self.headerContainer.backgroundColor = Colors.primary
        self.addShadow(to: headerContainer.layer, opacity: 0.8, height: 2)
        self.statusBar.backgroundColor = Colors.primary
        self.viewTitle.textColor = UIColor.white
        self.viewTitle.font = Fonts.getPrimaryHeavy(size: 17)
        self.ranchNameAndNumberLabel.textColor = UIColor.white
        self.ranchNameAndNumberLabel.font = Fonts.getPrimaryMedium(size: 14)
        self.saveToDraftButton.setTitleColor(UIColor.white, for: .normal)
        self.saveToDraftButton.titleLabel?.font = Fonts.getPrimaryHeavy(size: 17)
    }

    func styleMenu() {
        self.menuContainer.layer.cornerRadius = 5
        self.addShadow(to: menuContainer.layer, opacity: 0.8, height: 2)
        self.styleMenuSubmitButton()
        self.styleMenuLowerBars()
    }

    func styleMenuLowerBars() {
        self.basicInfoLowerBar.alpha = 0.1
        self.pasturesLowerBar.alpha = 0.1
        self.scheduleLowerBar.alpha = 0.1
    }

    func styleMenuSubmitButton() {
        self.reviewAndSubmitLabel.text = "Submit and Review"
        self.reviewAndSubmitBoxImage.image = #imageLiteral(resourceName: "boxUnchecked")
        self.submitButtonContainer.layer.cornerRadius = 5
        self.submitButtonContainer.backgroundColor = Colors.primary
        self.submitButtonContainer.layer.borderWidth = 1
    }

    func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.primary.cgColor
        button.setTitleColor(Colors.primary, for: .normal)
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
        self.ranchNameAndNumberLabel.alpha = 0
        self.saveToDraftButton.alpha = 0
        self.viewTitle.alpha = 0
    }

    func showHeaderContent() {
        self.ranchNameAndNumberLabel.alpha = 1
        self.saveToDraftButton.alpha = 1
        self.viewTitle.alpha = 1
    }

    func openingAnimations() {
        let defaultHeaderHeight: CGFloat = 60
        let showHeaderContentDelay = 0.2

        UIView.animate(withDuration: shortAnimationDuration, delay: showHeaderContentDelay, animations: {
            self.showHeaderContent()
            self.view.layoutIfNeeded()
        })

        UIView.animate(withDuration: shortAnimationDuration, animations: {
            self.headerHeight.constant = defaultHeaderHeight
            self.view.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: self.shortAnimationDuration, animations: {

                if UIDevice.current.orientation.isLandscape{
                    self.menuWidth.constant = self.landscapeMenuWidh
                } else if UIDevice.current.orientation.isPortrait {
                    self.menuWidth.constant = self.horizontalMenuWidth
                } else {
                    self.menuWidth.constant = self.landscapeMenuWidh
                }
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                UIView.animate(withDuration: self.shortAnimationDuration, animations: {
                    self.menuContainer.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    self.view.isUserInteractionEnabled = true
                })

            })
        }
    }

    func closingAnimations() {
        UIView.animate(withDuration: self.shortAnimationDuration, animations: {
            self.menuWidth.constant = 0
            self.menuContainer.alpha = 0
            self.view.layoutIfNeeded()
        })

        UIView.animate(withDuration: shortAnimationDuration, animations: {
            self.hideHeaderContent()
            self.headerHeight.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}
