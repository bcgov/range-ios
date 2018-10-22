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


enum PlanAction {
    case UpdateAmendment
    case ApproveAmendment
    case FinalReview
    case UpdateStatus
    case CreateMandatoryAmendment
    case CancelAmendment
    case PrepareForSubmission
}


// This extention has all the styling for create page.
extension CreateNewRUPViewController {

    // MARK: Styles
    func style() {
        styleNavBar(title: viewTitle, navBar: headerContainer, statusBar: statusBar, primaryButton: saveToDraftButton, secondaryButton: nil, textLabel: ranLabel)
        StyleNavBarButton(button: cancelButton)
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
            self.saveToDraftButton.setTitle("Save", for: .normal)
        }
    }

    func stylePlanActions() {
        guard let rup = self.rup else {return}
        planActions.alpha = 0
        roundCorners(layer: planActions.layer)
        planActionsButton.setTitleColor(Colors.inputText, for: .normal)
        planActionsButton.titleLabel?.font = Fonts.getPrimaryMedium(size: 15)
        //        planActionsButton.setTitleColor(.white, for: .normal)
        planActions.backgroundColor = Colors.inputBG

        updateAmendmentEnabled = (!getPlanActions(for: rup).isEmpty)

        if updateAmendmentEnabled {
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.planActions.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }

    func styleStatus() {
        styleNavBarLabel(label: statusAndagreementHolderLabel)
        makeCircle(view: statusLight)
        guard let plan = self.rup else {return}
        self.statusLight.backgroundColor = StatusHelper.getColor(for: plan.getStatus())
    }

    // MARK: Side Menu
    func setMenuSize() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
        }
        if self.view.frame.width > self.view.frame.height {
             styleLandscapeMenu()
        } else {
             stylePortaitMenu()
        }
//        if UIDevice.current.orientation.isLandscape{
//            styleLandscapeMenu()
//        } else if UIDevice.current.orientation.isPortrait {
//            stylePortaitMenu()
//        } else {
//            styleLandscapeMenu()
//        }
        self.animateIt()
    }

    func styleLandscapeMenu() {
        self.menuWidth.constant = self.landscapeMenuWidh
        setMenuLabelsAlpha(to: 1)
        setMenuIconLeadings(to: 10)
        self.submitButton.setTitle("Submit to client", for: .normal)
    }

    func stylePortaitMenu() {
        self.menuWidth.constant = self.portraitMenuWidth
        setMenuLabelsAlpha(to: 0)
        let imgWidth: CGFloat = 24
        let leftBar: CGFloat = 12
        setMenuIconLeadings(to: (portraitMenuWidth - imgWidth - leftBar)/2)
        self.submitButton.setTitle("", for: .normal)
    }

    func setMenuIconLeadings(to: CGFloat) {
        basicInfoIconLeading.constant = to
        pasturesIconLeading.constant = to
        scheduleIconLeading.constant = to
        ministersIssuesIconLeading.constant = to
        invasivePlantsIconLeading.constant = to
        additionalRequirementsIconLeading.constant = to
        managementIconLeading.constant = to
    }

    func setMenuLabelsAlpha(to alpha: CGFloat) {
        basicInfoLabel.alpha = alpha
        pasturesLabel.alpha = alpha
        scheduleLabel.alpha = alpha
        ministersIssuesLabel.alpha = alpha
        invasivePlantsLabel.alpha = alpha
        additionalRequirementsLabel.alpha = alpha
        managementLabel.alpha = alpha
        //        submitButton.alpha = alpha
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
        self.submitButton.backgroundColor = Colors.primary
        self.submitButton.layer.cornerRadius = 5

        if self.menuWidth.constant == self.portraitMenuWidth {
            self.submitButton.setTitle("", for: .normal)
        } else {
            self.submitButton.setTitle("Submit to client", for: .normal)
            if let label = self.submitButton.titleLabel {
                label.font = Fonts.getPrimaryMedium(size: 17)
                label.change(kernValue: -0.32)
            }

        }

        self.requiredFieldNeededLabel.alpha = 0
    }

    func styleMenuSubmitButtonOFF() {

        self.submitButton.backgroundColor = Colors.primary
        self.submitButton.layer.cornerRadius = 5

        if self.menuWidth.constant == self.portraitMenuWidth {
            self.submitButton.setTitle("", for: .normal)
        } else {
            self.submitButton.setTitle("Submit to client", for: .normal)
            if let label = self.submitButton.titleLabel {
                label.font = Fonts.getPrimaryMedium(size: 17)
                label.change(kernValue: -0.32)
            }
        }

        self.requiredFieldNeededLabel.alpha = 1
        self.requiredFieldNeededLabel.text = "Missing required fields"
        self.styleFieldHeader(label: self.requiredFieldNeededLabel)
        self.requiredFieldNeededLabel.textColor = Colors.invalid
    }

    // MARK: Menu Items

    func styleMenuLowerBars() {
        self.basicInfoLowerBar.alpha = 0.1
        self.pasturesLowerBar.alpha = 0.1
        self.scheduleLowerBar.alpha = 0.1
        self.ministersIssuesLowerBar.alpha = 0.1
        self.invasivePlantsLowerBar.alpha = 0.1
        self.additionalRequirementsLowerBar.alpha = 0.1
        self.managementLowerBar.alpha = 0.1
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

    func menuInvasivePlantsOn() {
        menuSectionsOff()
        invasivePlantsBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: invasivePlantsLabel)
        invasivePlantsBoxImage.image = UIImage(named: "icon_invasivePlants")
    }

    func menuAdditionalRequirementsOn() {
        menuSectionsOff()
        additionalRequirementsBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: additionalRequirementsLabel)
        additionalRequirementsImage.image = UIImage(named: "icon_additionalReqs")
    }

    func menuManagementConsiderationsOn() {
        menuSectionsOff()
        managementBoxLeft.backgroundColor = Colors.secondary
        menuSectionOn(label: managementLabel)
        managementBoxImage.image =  UIImage(named: "icon_Management")
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

        menuSectionOff(label: invasivePlantsLabel)
        invasivePlantsBoxImage.image = UIImage(named: "icon_invasivePlants_off")
        invasivePlantsBoxLeft.backgroundColor = UIColor.clear

        menuSectionOff(label: additionalRequirementsLabel)
        additionalRequirementsImage.image = UIImage(named: "icon_additionalReqs_off")
        additionalRequirementsBoxLeft.backgroundColor = UIColor.clear

        menuSectionOff(label: managementLabel)
        managementBoxImage.image = UIImage(named: "icon_Management_off")
        managementBoxLeft.backgroundColor = UIColor.clear

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
                    self.stylePlanActions()
                    return callBack()
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
