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

extension CreateNewRUPViewController {
    // MARK: Styles
    func style() {
        
        stylePopUp()
        styleNavBar(title: viewTitle, navBar: headerContainer, statusBar: statusBar, primaryButton: saveToDraftButton, secondaryButton: nil, textLabel: ranLabel)
        StyleNavBarButton(button: cancelButton)
        StyleNavBarButton(button: updateAmendmentButton)
        styleMenu()

        switch mode {
        case .View:
            self.viewTitle.text = "View Plan"
            self.saveToDraftButton.setTitle("Close", for: .normal)
            self.ranLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 10).isActive = true
            self.cancelButton.removeFromSuperview()
            self.submitButtonContainer.alpha = 0
            self.requiredFieldNeededLabel.alpha = 0
        case .Edit:
            self.viewTitle.text = "Create New RUP"
            self.saveToDraftButton.setTitle("Save to Draft", for: .normal)
        }
    }

    func styleUpdateAmendmentButton() {
        guard let rup = self.rup else {return}

        let current = rup.getStatus()
        if current == .Stands {
            updateAmendmentButton.setTitle("Update Amendment", for: .normal)
            updateAmendmentEnabled = true
        } else if current == .SubmittedForFinalDecision || current == .SubmittedForReview {
            updateAmendmentButton.setTitle("Approve Amendment", for: .normal)
            updateAmendmentEnabled = true
        } else if current == .RecommendReady {
            updateAmendmentButton.setTitle("Final Review", for: .normal)
            updateAmendmentEnabled = true
        }else {
            updateAmendmentEnabled = false
        }
        
        self.updateAmendmentButton.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
            if self.updateAmendmentEnabled {
                self.updateAmendmentButton.alpha = 1
            } else {
                self.updateAmendmentButton.alpha = 0
            }
            self.view.layoutIfNeeded()
        })
    }

    func styleStatus() {
        styleNavBarLabel(label: statusAndagreementHolderLabel)
        makeCircle(view: statusLight)
        guard let plan = self.rup else {return}
        switch plan.getStatus() {
        case .Completed:
            setStatusGreen()
        case .Pending:
            setStatusYellow()
        case .LocalDraft:
            setStatusRed()
        case .Outbox:
            setStatusGray()
        case .Created:
            setStatusYellow()
        case .ChangeRequested:
            setStatusGray()
        case .ClientDraft:
            setStatusRed()
        case .Unknown:
            setStatusGray()
        case .StaffDraft:
            setStatusGreen()
        case .WronglyMadeWithoutEffect:
            setStatusGray()
        case .StandsWronglyMade:
            setStatusGray()
        case .Stands:
            setStatusGray()
        case .NotApprovedFurtherWorkRequired:
            setStatusGray()
        case .NotApproved:
            setStatusGray()
        case .Approved:
            setStatusGray()
        case .SubmittedForReview:
            setStatusGray()
        case .SubmittedForFinalDecision:
            setStatusGray()
        case .RecommendReady:
            setStatusGray()
        case .RecommendNotReady:
            setStatusGray()
        case .ReadyForFinalDescision:
            setStatusGray()
        }
    }

    func setStatusRed() {
        self.statusLight.backgroundColor = UIColor.red
    }

    func setStatusGreen() {
        self.statusLight.backgroundColor = UIColor.green
    }

    func setStatusYellow() {
        self.statusLight.backgroundColor = UIColor.yellow
    }

    func setStatusGray() {
        self.statusLight.backgroundColor = UIColor.gray
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
            styleLandscapeMenu()
        } else if UIDevice.current.orientation.isPortrait {
            stylePortaitMenu()
        } else {
            styleLandscapeMenu()
        }
        self.animateIt()
    }

    func styleLandscapeMenu() {
        self.menuWidth.constant = self.landscapeMenuWidh
        setMenuLabelsAlpha(to: 1)
        setMenuIconLeadings(to: 2)
        reviewAndSubmitButton.setImage(.none, for: .normal)
        self.reviewAndSubmitBoxImage.alpha = 1
    }

    func stylePortaitMenu() {
        self.menuWidth.constant = self.portraitMenuWidth
        setMenuLabelsAlpha(to: 0)
        reviewAndSubmitButton.setImage(#imageLiteral(resourceName: "icon_check_white"), for: .normal)
        let imgWidth: CGFloat = 24
        let leftBar: CGFloat = 12
        setMenuIconLeadings(to: (portraitMenuWidth - imgWidth - leftBar)/2)
        self.reviewAndSubmitBoxImage.alpha = 0
    }

    func setMenuIconLeadings(to: CGFloat) {
        basicInfoIconLeading.constant = to
        pasturesIconLeading.constant = to
        scheduleIconLeading.constant = to
        ministersIssuesIconLeading.constant = to
    }

    func setMenuLabelsAlpha(to alpha: CGFloat) {
        basicInfoLabel.alpha = alpha
        pasturesLabel.alpha = alpha
        scheduleLabel.alpha = alpha
        ministersIssuesLabel.alpha = alpha
        reviewAndSubmitLabel.alpha = alpha
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
        self.reviewAndSubmitLabel.text = "Submit to client"
        self.reviewAndSubmitBoxImage.image = #imageLiteral(resourceName: "icon_check_white")
        self.reviewAndSubmitButton.isEnabled = true
        self.requiredFieldNeededLabel.alpha = 0

        self.submitButtonContainer.layer.cornerRadius = 5
        self.submitButtonContainer.backgroundColor = Colors.primary
        self.submitButtonContainer.layer.borderWidth = 1
        self.submitButtonContainer.alpha = 1
    }

    func styleMenuSubmitButtonOFF() {
        self.reviewAndSubmitLabel.text = "Submit to client"
        self.reviewAndSubmitBoxImage.image = #imageLiteral(resourceName: "icon_check_white")
        self.reviewAndSubmitButton.isEnabled = false
        self.requiredFieldNeededLabel.alpha = 1
        self.requiredFieldNeededLabel.text = "Missing required fields"
        self.styleFieldHeader(label: self.requiredFieldNeededLabel)
        self.requiredFieldNeededLabel.textColor = Colors.invalid

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
                    // MARK: End of opening animations
                    self.view.isUserInteractionEnabled = true
                    self.styleUpdateAmendmentButton()
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
