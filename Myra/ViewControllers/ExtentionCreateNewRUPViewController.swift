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
        stylePopUp()
        styleNavBar(title: viewTitle, navBar: headerContainer, statusBar: statusBar, primaryButton: saveToDraftButton, secondaryButton: nil, textLabel: ranchNameAndNumberLabel)
        StyleNavBarButton(button: cancelButton)
        styleMenu()
        switch mode {
        case .View:
            self.viewTitle.text = "View Plan"
            self.saveToDraftButton.setTitle("Close", for: .normal)
            self.submitButtonContainer.alpha = 0
            ranchNameAndNumberLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 10).isActive = true
            cancelButton.removeFromSuperview()
        case .Edit:
            self.viewTitle.text = "Create New RUP"
            self.saveToDraftButton.setTitle("Save to Draft", for: .normal)
            self.submitButtonContainer.alpha = 1
        }
    }

    // TODO: Temporary.. come up with a better, resusable popup for inputs
    func stylePopUp() {
        styleContainer(view: popupVIew)
        popupVIew.backgroundColor = UIColor.white
        styleFieldHeader(label: popupTitle)
        styleInput(input: popupTextField, height: popupInputHeight)
        grayScreen.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.9)
        styleHollowButton(button: popupCancelButton)
        styleHollowButton(button: popupAddButton)
    }

    // MARK: Side Menu
    func setMenuSize() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
        }
        if UIDevice.current.orientation.isLandscape{
            self.menuWidth.constant = self.landscapeMenuWidh
        } else {
            self.menuWidth.constant = self.portraitMenuWidth
        }
        self.animateIt()
    }

    func styleMenu() {
        self.menuSectionsOff()
        self.menuContainer.layer.cornerRadius = 5
        self.addShadow(to: menuContainer.layer, opacity: 0.8, height: 2)
        if let r = rup, r.isValid {
            self.styleMenuSubmitButtonOn()
        } else {
            self.styleMenuSubmitButtonOFF()
        }
        self.styleMenuLowerBars()
    }

    // MARK: Submit Button
    func styleMenuSubmitButtonOn() {
        self.reviewAndSubmitLabel.text = "Review and Submit"
        self.reviewAndSubmitBoxImage.image = #imageLiteral(resourceName: "icon_check_white")
        self.reviewAndSubmitButton.isEnabled = true

        self.submitButtonContainer.layer.cornerRadius = 5
        self.submitButtonContainer.backgroundColor = Colors.primary
        self.submitButtonContainer.layer.borderWidth = 1
        self.submitButtonContainer.alpha = 1
    }

    func styleMenuSubmitButtonOFF() {
        self.reviewAndSubmitLabel.text = "Review and Submit"
        self.reviewAndSubmitBoxImage.image = #imageLiteral(resourceName: "icon_check_white")
        self.reviewAndSubmitButton.isEnabled = false

        self.submitButtonContainer.layer.cornerRadius = 5
        self.submitButtonContainer.backgroundColor = Colors.primary
        self.submitButtonContainer.layer.borderWidth = 1
        self.submitButtonContainer.alpha = 0.5
    }

    // MARK: Menu Items

    func styleMenuLowerBars() {
        self.basicInfoLowerBar.alpha = 0.1
        self.pasturesLowerBar.alpha = 0.1
        self.scheduleLowerBar.alpha = 0.1
        self.ministersIssuesLowerBar.alpha = 0.1
    }

    func menuBasicInfoOn() {
        menuSectionsOff()
        basicInfoBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: basicInfoLabel)
        basicInfoBoxImage.image = #imageLiteral(resourceName: "icon_basicInformation")
    }

    func menuPastureOn() {
        menuSectionsOff()
        pastureBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: pasturesLabel)
        pasturesBoxImage.image = #imageLiteral(resourceName: "icon_Pastures")
    }

    func menuScheduleOn() {
        menuSectionsOff()
        scheduleBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: scheduleLabel)
        scheduleBoxImage.image = #imageLiteral(resourceName: "icon_Schedule")
    }

    func menuMinistersIssuesOn() {
        menuSectionsOff()
        ministersIssuesBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: ministersIssuesLabel)
        ministersIssuesBoxImage.image = #imageLiteral(resourceName: "icon_MinistersIssues")
    }

    func menuSectionsOff() {
        menuSectionOff(label: basicInfoLabel)
        basicInfoBoxImage.image = #imageLiteral(resourceName: "icon_basicInformation_off")
        basicInfoBoxLeft.backgroundColor = UIColor.clear

        menuSectionOff(label: pasturesLabel)
        pasturesBoxImage.image = #imageLiteral(resourceName: "icon_Pastures_off")
        pastureBoxLeft.backgroundColor = UIColor.clear

        menuSectionOff(label: scheduleLabel)
        scheduleBoxImage.image = #imageLiteral(resourceName: "icon_Schedule_off")
        scheduleBoxLeft.backgroundColor = UIColor.clear

        menuSectionOff(label: ministersIssuesLabel)
        ministersIssuesBoxImage.image = #imageLiteral(resourceName: "icon_MinistersIssues_off")
        ministersIssuesBoxLeft.backgroundColor = UIColor.clear

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
                    self.menuWidth.constant = self.portraitMenuWidth
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
