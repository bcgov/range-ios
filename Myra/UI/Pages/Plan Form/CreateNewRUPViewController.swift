//
//  CreateNewRUPViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import IQKeyboardManagerSwift

enum AcceptedPopupInput {
    case String
    case Double
    case Integer
    case Year
}

public enum BasicInfoRow: Int, CaseIterable {
    case BasicInfo = 0
    case PlanInfo
    case AgreementHolders
    case Usage
}

public enum FromSection: Int, CaseIterable {
    case BasicInfo = 0
    case Pastures
    case YearlySchedule
    case MinistersIssues
    case InvasivePlants
    case AdditionalRequirements
    case ManagementConsiderations
    case Map
}

class CreateNewRUPViewController: BaseViewController {
    
    // MARK: Constants
    let landscapeMenuWidh: CGFloat = 265
    let portraitMenuWidth: CGFloat = 64
    let numberOfSections = 11
    
    var menuView: FormMenu?
    
    // MARK: Variables
    var rup: Plan?
    
    var updateAmendmentEnabled = false
    
    var planCopy: Plan?
    
    var reloading: Bool = false
    
    var mode: FormMode = .View
    
    var realmNotificationToken: NotificationToken?
    
    var planIsValid: Bool = false {
        didSet {
            if planIsValid {
                self.setSubmitButton(valid: true)
            } else {
                self.setSubmitButton(valid: false)
            }
        }
    }
    
    var lastKnowContentOfsset: CGFloat = 0
    var bannerShown: Bool = false
    
    // MARK: Outlets
    
    // TOP
    @IBOutlet weak var statusbar: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var ranLabel: UILabel!
    
    @IBOutlet weak var statusLight: UIView!
    
    @IBOutlet weak var statusAndagreementHolderLabel: UILabel!
    
    @IBOutlet weak var saveToDraftButton: UIButton!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    
    // Banner
    @IBOutlet weak var bannerContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerActionButton: UIButton!
    @IBOutlet weak var bannerTitle: UILabel!
    @IBOutlet weak var bannerSubtitle: UILabel!
    @IBOutlet weak var bannerActionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var bannerTopConstraint: NSLayoutConstraint!
    
    // Side Menu
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var menuLeading: NSLayoutConstraint!
    
    @IBOutlet weak var menuModeButton: UIButton!
    
    // Body
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        prePresentation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openingAnimations(callBack: {
            self.whenPresented()
        })
    }
    
    func prePresentation() {
        style()
        setMenuSize()
        setUpTable()
        autofill()
        prepareToAnimate()
    }
    
    func whenPresented() {
        self.openBannerIfNeeded()
        let minPlanFieldsMessage = self.minimumPlanFieldsAreFilledMessage()
        if !minPlanFieldsMessage.isEmpty {
            Alert.show(title: "Heads up!", message: minPlanFieldsMessage)
        }
    }
    
    func reload() {
        prePresentation()
        openingAnimations(callBack: {
            self.whenPresented()
        })
    }
    
    func minimumPlanFieldsAreFilledMessage() -> String {
        guard let plan = self.rup  else {
            return ""
        }
        var message = ""
        if plan.rangeName.isEmpty {
            message = "\(message)Range Name\n"
        }
        if plan.planStartDate == nil {
            message = "\(message)Plan Start date\n"
        }
        
        if plan.planEndDate == nil {
            message = "\(message)Plan End date\n"
        }
        if message.isEmpty {
            return message
        } else {
            let messageDesc = "This plan will not be uploaded until these minimum fields are filled:\n\n"
            return "\(messageDesc)\(message)"
        }
    }
    
    // MARK: Outlet Actions
    @IBAction func menuModeAction(_ sender: UIButton) {
//        if self.menuWidth.constant ==  self.portraitMenuWidth {
//            styleLandscapeMenu()
//        } else {
//            stylePortaitMenu()
//        }
        animateIt()
    }
    
    @IBAction func bannerActionButtonClicked(_ sender: UIButton) {
        guard let plan = self.rup else {return}
        FlowHelper.shared.beginflow(for: plan) { (flowResult) in
            if let result = flowResult {
                plan.updateStatus(with: result.status, note: result.notes)
                self.saveAndClose()
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismissKeyboard()
        Alert.show(title: "Are you sure?", message: "Your changes since the last time you saved will be lost", yes: {
            self.cancel()
        }) {
            return
        }
    }
    
    func cancel() {
        dismissKeyboard()
        guard let new: Plan = self.planCopy, let old: Plan = self.rup, let agreement = RUPManager.shared.getAgreement(with: new.agreementId) else {
            Alert.show(title: "Critical Error", message: "A critical error prevents the recovery of the old version of this plan. The current version is saved.")
            return
        }
        
        // If is not new (not just created from agreement)
        // Store the copy created before changes.
        if !old.isNew {
            // save copy
            RealmRequests.saveObject(object: new)
            
            // add plan to appropriate agreement
            agreement.add(plan: new)
            
            // remove modified RUP object
            old.deleteSubEntries()
            RealmRequests.deleteObject(old)
        }
        
        // ELSE it you came here from agreement selection, and changed your mind.
        // dont store any rup
        
        self.goHome()
    }
    
    @IBAction func saveToDraftAction(_ sender: UIButton) {
        self.saveAndClose()
    }
    
    func saveAndClose() {
        guard let plan = self.rup else {return}
        AutoSync.shared.endListener()
        do {
            let realm = try Realm()
            try realm.write {
                plan.isNew = false
                plan.locallyUpdatedAt = Date()
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        
        RealmRequests.updateObject(plan)
        
        self.goHome()
    }
    
    func submitAction() {
        guard let plan = self.rup else {return}
        AutoSync.shared.endListener()
        
        let validity = RUPManager.shared.isValid(rup: plan)
        if !validity.0 {
            alert(with: "Plan is invalid", message: validity.1)
            return
        }

        closingAnimations()
        showAlert(title: "Confirm", description: "You will not be able to edit this RUP after submission", yesButtonTapped: {
            // Yes tapped
            do {
                let realm = try Realm()
                try realm.write {
                    plan.isNew = false
                    plan.statusEnum = .Outbox
                }
            } catch _ {}
            self.goHome()
        }) {
            // No tapped
            self.openingAnimations(callBack: {
            })
        }
    }
    
    // MARK: Functions
    func refreshPlanObject() {
        guard let plan = self.rup else {return}
        do {
            let realm = try Realm()
            let aRup = realm.objects(Plan.self).filter("localId = %@", plan.localId).first!
            self.rup = aRup
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }
    
    func goHome() {
        if let presenter = getPresenter() {
            dismissKeyboard()
            endChangeListener()
            self.rup = nil
            self.planCopy = nil
            NotificationCenter.default.post(name: .planClosed, object: nil)
            presenter.goHome()
        }
    }
    
    // MARK: Setup
    // TODO: Remove callback options. empty callback is good enough
    func setup(rup: Plan, mode: FormMode) {
        self.rup = rup
        self.mode = mode
        self.planCopy = nil
        
        switch mode {
        case .View:
            break
        case .Edit:
            /*
             Create copy.
             If cancel is pressed, store copy and delete rup
             Otherwise don't save the Plan copy object.
             */
            self.planCopy = rup.clone()
            do {
                let realm = try Realm()
                try realm.write {
                    rup.statusEnum = .LocalDraft
                }
                self.rup = rup
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
        }

        setUpTable()
        
        if rup.getStatus() == .StaffDraft || rup.getStatus() == .LocalDraft {
            beginChangeListener()
        }
    }
    
    func beginChangeListener() {
        guard let r = self.rup else { return}
        Logger.log(message: "Listening to Changes in plan \(r.ranNumber).")
        self.realmNotificationToken = r.observe { (change) in
            switch change {
            case .error:
                Logger.log(message: "Error in Plan \(r.ranNumber) change.")
            case .change:
                Logger.log(message: "Change observed in plan \(r.ranNumber).")
                self.planIsValid = r.isValid
                self.notifyPlanChanged()
                Logger.log(message: "Sent Notification for change in plan \(r.ranNumber).")
            case .deleted:
                //Logger.log(message: "Plan  \(r.ranNumber) deleted.")
                self.endChangeListener()
            }
        }
    }
    
    func notifyPlanChanged() {
        NotificationCenter.default.post(name: .planChanged, object: nil)
    }
    
    func endChangeListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            Logger.log(message: "Stopped Listening to Changes in plan :(")
        }
    }
    
    func autofill() {
        guard let rup = self.rup else { return}
        if rup.getStatus() == .Stands {
            updateAmendmentEnabled = true
        } else {
            updateAmendmentEnabled = false
        }
        self.setBarInfoBasedOnOrientation()
        self.hightlightAppropriateMenuItem()
    }
    
    func setBarInfoBasedOnOrientation() {
        guard let p = rup else { return }
        var holder = ""
        
        if let agreement = RUPManager.shared.getAgreement(with: p.agreementId) {
            holder = agreement.primaryAgreementHolder()
        }
        
        ranLabel.text = "\(p.agreementId) | "
        let planStatus = StatusHelper.getDescription(for: p).displayName
        if UIDevice.current.orientation.isPortrait ||  UIDevice.current.orientation.isFlat {
            statusAndagreementHolderLabel.text = "\(planStatus)"
        } else {
            statusAndagreementHolderLabel.text = "\(planStatus) | \(holder)"
        }
        
        styleStatus()
        animateIt()
    }
    
    func catchAction(notification: Notification) {
        if !reloading {
            self.tableView.reloadData()
            self.reloading = true
        } else {
            self.reloading = false
        }
    }
    
    override func whenLandscape() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        setBarInfoBasedOnOrientation()
        openBannerIfNeeded(closeFirst: false)
    }
    
    override func whenPortrait() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        setBarInfoBasedOnOrientation()
        openBannerIfNeeded(closeFirst: false)
    }
}

// MARK: Tableview
extension CreateNewRUPViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        tableView.remembersLastFocusedIndexPath = true
        registerCell(name: "BasicInformationTableViewCell")
        registerCell(name: "PlanInformationTableViewCell")
        registerCell(name: "AgreementHoldersTableViewCell")
        registerCell(name: "BasicInfoSectionTwoTableViewCell")
        registerCell(name: "AgreementInformationTableViewCell")
        registerCell(name: "LiveStockIDTableViewCell")
        registerCell(name: "RangeUsageTableViewCell")
        registerCell(name: "PasturesTableViewCell")
        registerCell(name: "MapTableViewCell")
        registerCell(name: "ScheduleTableViewCell")
        registerCell(name: "MinisterIssuesTableViewCell")
        registerCell(name: "InvasivePlantsTableViewCell")
        registerCell(name: "AdditionalRequirementsTableViewCell")
        registerCell(name: "ManagementConsiderationsTableViewCell")
    }
    
    @objc func doThisWhenNotify() { return }
    
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getBasicInfoCell(indexPath: IndexPath) -> BasicInformationTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "BasicInformationTableViewCell", for: indexPath) as! BasicInformationTableViewCell
    }
    
    func getPlanInformationCell(indexPath: IndexPath) -> PlanInformationTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlanInformationTableViewCell", for: indexPath) as! PlanInformationTableViewCell
    }
    
    func getAgreementHoldersCell(indexPath: IndexPath) -> AgreementHoldersTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AgreementHoldersTableViewCell", for: indexPath) as! AgreementHoldersTableViewCell
    }
    
    func getRangeUsageCell(indexPath: IndexPath) -> RangeUsageTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "RangeUsageTableViewCell", for: indexPath) as! RangeUsageTableViewCell
    }
    
    func getLiveStockIDTableViewCell(indexPath: IndexPath) -> LiveStockIDTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LiveStockIDTableViewCell", for: indexPath) as! LiveStockIDTableViewCell
    }
    
    func getPasturesCell(indexPath: IndexPath) -> PasturesTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PasturesTableViewCell", for: indexPath) as! PasturesTableViewCell
    }
    
    func getScheduleCell(indexPath: IndexPath) -> ScheduleTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
    }
    
    func getMinistersIssuesCell(indexPath: IndexPath) -> MinisterIssuesTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MinisterIssuesTableViewCell", for: indexPath) as! MinisterIssuesTableViewCell
    }
    
    func getInvasivePlantsCell(indexPath: IndexPath) -> InvasivePlantsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "InvasivePlantsTableViewCell", for: indexPath) as! InvasivePlantsTableViewCell
    }
    
    func getAdditionalRequirementsCell(indexPath: IndexPath) -> AdditionalRequirementsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AdditionalRequirementsTableViewCell", for: indexPath) as! AdditionalRequirementsTableViewCell
    }
    
    func getManagementConsiderationsCell(indexPath: IndexPath) -> ManagementConsiderationsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ManagementConsiderationsTableViewCell", for: indexPath) as! ManagementConsiderationsTableViewCell
    }
    
    func getMapCell(indexPath: IndexPath) -> MapTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
    }
    
    func getBasicInfoRow(at indexPath: IndexPath) -> UITableViewCell {
        guard let plan = rup, let rowType = BasicInfoRow(rawValue: Int(indexPath.row)) else {return UITableViewCell()}
        switch rowType {
        case .BasicInfo:
            let cell = getBasicInfoCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .PlanInfo:
            let cell = getPlanInformationCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .AgreementHolders:
            let cell = getAgreementHoldersCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .Usage:
            let cell = getRangeUsageCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let plan = rup, let sectionType = FromSection(rawValue: Int(indexPath.section)) else {return UITableViewCell()}
        switch sectionType {
        case .BasicInfo:
            return getBasicInfoRow(at: indexPath)
        case .Pastures:
            let cell = getPasturesCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .YearlySchedule:
            let cell = getScheduleCell(indexPath: indexPath)
            // passing self reference because cells within this cell's tableview need to call showAlert()
            cell.setup(mode: mode, rup: plan, parentReference: self)
            return cell
        case .MinistersIssues:
            let cell = getMinistersIssuesCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .InvasivePlants:
            let cell = getInvasivePlantsCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .AdditionalRequirements:
            let cell = getAdditionalRequirementsCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .ManagementConsiderations:
            let cell = getManagementConsiderationsCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: plan)
            return cell
        case .Map:
            let cell = getMapCell(indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionType = FromSection(rawValue: section), sectionType == .BasicInfo {
            return BasicInfoRow.allCases.count
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if SettingsManager.shared.isFormMapSectionEnabled() {
            return FromSection.allCases.count
        } else {
            return FromSection.allCases.count - 1
        }
    }
    
    // RELOAD WITH COMPLETION
    func reload(then: @escaping() -> Void) {
        refreshPlanObject()
        if #available(iOS 11.0, *) {
            self.tableView.performBatchUpdates({
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }, completion: { done in
                self.tableView.layoutIfNeeded()
                if !done {
                    print (done)
                }
                self.hightlightAppropriateMenuItem()
                return then()
            })
        } else {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.layoutIfNeeded()
            self.hightlightAppropriateMenuItem()
            return then()
        }
    }
    
    func reload(at section: FromSection) {
        let indexPath = getIndexPath(forSection: section)
        refreshPlanObject()
        if #available(iOS 11.0, *) {
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.layoutIfNeeded()
        }
    }
    
    // Note:
    // For basicInfo section, return's Usage rown's indexpath.
    func getIndexPath(forSection section: FromSection) -> IndexPath {
        var row = 0
        if section == .BasicInfo {row = BasicInfoRow.Usage.rawValue}
        return IndexPath(row: row, section: section.rawValue)
    }
    
    func realod(bottomOf section: FromSection, then: @escaping() -> Void) {
        reload {
            self.tableView.scrollToRow(at: self.getIndexPath(forSection: section), at: .bottom, animated: true)
            self.hightlightAppropriateMenuItem()
            return then()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .formScrolled, object: nil)
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
             self.HideBanner()
        }
        else {
            self.ShowBanner()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .formEndedStrolling, object: nil)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastKnowContentOfsset = scrollView.contentOffset.y
    }
    
    func hightlightAppropriateMenuItem() {
        if let menuView = self.menuView {
            menuView.highlightAppropriateMenuItem()
        }
    }
}

// MARK: Banner
extension CreateNewRUPViewController {
    func openBannerIfNeeded(closeFirst: Bool = true) {
        guard let plan = self.rup else {return}
        
        if closeFirst {
            setBannerClosedSize()
        }
        
        let stausDesc = StatusHelper.getDescription(for: plan)
        openBannerWith(title: stausDesc.bannerTitle, subititle: stausDesc.bannerDescription, actionButtonTitle: FlowHelper.shared.getActionName(for: plan) ?? "", hideFirst: closeFirst)
    }
    
    func getBannerTitle() -> String {
        guard let plan = self.rup, let amendmentType = Reference.shared.getAmendmentType(forId: plan.amendmentTypeId) else {return ""}
        if amendmentType.name.lowercased().contains("minor") {
            return bannerMinorAmendmentReviewRequiredTitle
        } else {
            return bannerMandatoryAmendmentReviewRequiredTitle
        }
    }
    
    func getBannerDescription() -> String {
        guard let plan = self.rup, let amendmentType = Reference.shared.getAmendmentType(forId: plan.amendmentTypeId) else {return ""}
        if amendmentType.name.lowercased().contains("minor") {
            return bannerMinorAmendmentReviewRequiredDescription
        } else {
            return bannerMandatoryAmendmentReviewRequiredTitle
        }
    }
    
    func openBannerWith(title: String, subititle: String, actionButtonTitle: String = "", hideFirst: Bool = true) {
        // set text
        self.bannerTitle.text = title
        self.bannerSubtitle.text = subititle
        self.bannerActionButton.setTitle(actionButtonTitle, for: .normal)
        // style
        self.bannerTitle.textColor = Colors.technical.mainText
        self.bannerTitle.font = Fonts.getPrimaryBold(size: 22)
        self.bannerSubtitle.textColor = Colors.technical.mainText
        self.bannerSubtitle.font = Fonts.getPrimary(size: 17)
        self.styleFillButton(button: bannerActionButton)
        // prepare animated presentation
        if hideFirst {
            self.bannerContainer.alpha = 0
        }
        self.view.layoutIfNeeded()
        // animate height change
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            self.setBannerSizes(title: title, subititle: subititle, actionButtonTitle: actionButtonTitle)
            self.view.layoutIfNeeded()
        }) { (done) in
            // animate presentation (alpha change)
            UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration()) {
                self.view.layoutIfNeeded()
                self.bannerContainer.backgroundColor = Colors.accent.yellow
                self.bannerContainer.alpha = 1
            }
        }
    }
    
    func setBannerSizes(title: String, subititle: String, actionButtonTitle: String = "") {
        // Extra padding
        let extraPadding: CGFloat = 16
        // Sum of verstial spaces between elements
        let verticalPaddings: CGFloat = 32
        
        // add extra vertical size to button
        var buttonPadding: CGFloat = 16
        
        if actionButtonTitle.isEmpty {
            buttonPadding = 0
        }
        if let actionButtonWidth = actionButtonTitle.width(for: bannerActionButton) {
            bannerActionButtonWidth.constant = actionButtonWidth + buttonPadding
        }
        if actionButtonTitle.isEmpty {
            bannerActionButton.alpha = 0
        }
        let titleHeight = title.height(for: bannerTitle, subtractWidth: bannerActionButtonWidth.constant)
        let subtitleHeight = subititle.height(for: bannerSubtitle, subtractWidth: bannerActionButtonWidth.constant)
        let computedBannerHeight = (titleHeight + subtitleHeight + verticalPaddings)
        bannerTopConstraint.constant = 0
        bannerContainerHeight.constant = computedBannerHeight + extraPadding
        self.bannerShown = true
    }
    
    func setBannerClosedSize() {
        self.bannerContainer.alpha = 0
        self.bannerTopConstraint.constant = 0 - (self.bannerContainer.frame.height)
        self.bannerShown = false
    }
    
    func ShowBanner() {
        if bannerShown {return}
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration()) {
            self.bannerTopConstraint.constant = 0
            self.bannerContainer.alpha = 1
            self.bannerShown = true
            self.view.layoutIfNeeded()
        }
    }
    
    func HideBanner() {
        if !bannerShown {return}
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration()) {
            self.bannerTopConstraint.constant = 0 - (self.bannerContainer.frame.height)
            self.bannerContainer.alpha = 0
            self.bannerShown = false
            self.view.layoutIfNeeded()
        }
    }
    
    func closeBanner() {
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
           self.setBannerClosedSize()
        }) { (done) in }
    }
}
