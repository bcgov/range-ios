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

public enum FromSection: Int, CaseIterable {
    case BasicInfo = 0
    case PlanInfo
    case AgreementHolders
    case Usage
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
  
    /* need to hold the inxedpath of sections to be able to scroll back to them.
     at this point, the indexpaths of the sections may not be known, and change
     at runtime.
     */
    var basicInformationIndexPath: IndexPath = [0,0]
    var agreementInformationIndexPath: IndexPath = [0,0]
    var liveStockIDIndexPath: IndexPath = [0,0]
    var rangeUsageIndexPath: IndexPath = [0,0]
    var pasturesIndexPath: IndexPath = [0,0]
    var scheduleIndexPath: IndexPath = [0,0]
    var minsterActionsIndexPath: IndexPath = [0,0]
    var invasivePlantsIndexPath: IndexPath = [0,0]
    var additionalRequirementsIndexPath: IndexPath = [0,0]
    var managementIndexPath: IndexPath = [0,0]
    var mapIndexPath: IndexPath = [0,0]
    
    var rup: Plan?
    
    var updateAmendmentEnabled = false
    
    var planCopy: Plan?
    
    var reloading: Bool = false
    
    var mode: FormMode = .View
    
    var realmNotificationToken: NotificationToken?
    
    var planIsValid: Bool = false {
        didSet {
            if planIsValid {
                self.styleMenuSubmitButtonOn()
            } else {
                self.styleMenuSubmitButtonOFF()
            }
        }
    }
    
    // pop up for adding pastures and years
    var acceptedPopupInput: AcceptedPopupInput = .String
    var popupCompletion: ((_ done: Bool,_ result: String) -> Void )?
    var popupTakenValues: [String] = [String]()
    
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
    
    @IBOutlet weak var planActionsButton: UIButton!
    @IBOutlet weak var planActionsDropdownButton: UIButton!
    @IBOutlet weak var planActions: UIView!
    
    // Banner
    @IBOutlet weak var bannerContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerTitle: UILabel!
    @IBOutlet weak var bannerTooltip: UIButton!
    
    // Side Menu
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var menuLeading: NSLayoutConstraint!
    
    @IBOutlet weak var basicInfoLowerBar: UIView!
    @IBOutlet weak var basicInfoBox: UIView!
    @IBOutlet weak var basicInfoLabel: UILabel!
    @IBOutlet weak var basicInfoButton: UIButton!
    @IBOutlet weak var basicInfoBoxImage: UIImageView!
    @IBOutlet weak var basicInfoBoxLeft: UIView!
    @IBOutlet weak var basicInfoIconLeading: NSLayoutConstraint!
    
    @IBOutlet weak var pasturesBox: UIView!
    @IBOutlet weak var pasturesLabel: UILabel!
    @IBOutlet weak var pasturesButton: UIButton!
    @IBOutlet weak var pasturesBoxImage: UIImageView!
    @IBOutlet weak var pasturesLowerBar: UIView!
    @IBOutlet weak var pastureBoxLeft: UIView!
    @IBOutlet weak var pasturesIconLeading: NSLayoutConstraint!
    
    @IBOutlet weak var scheduleBox: UIView!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var scheduleBoxImage: UIImageView!
    @IBOutlet weak var scheduleLowerBar: UIView!
    @IBOutlet weak var scheduleBoxLeft: UIView!
    @IBOutlet weak var scheduleIconLeading: NSLayoutConstraint!
    
    @IBOutlet weak var ministersIssuesBox: UIView!
    @IBOutlet weak var ministersIssuesLabel: UILabel!
    @IBOutlet weak var ministersIssuesButton: UIButton!
    @IBOutlet weak var ministersIssuesBoxImage: UIImageView!
    @IBOutlet weak var ministersIssuesLowerBar: UIView!
    @IBOutlet weak var ministersIssuesBoxLeft: UIView!
    @IBOutlet weak var ministersIssuesIconLeading: NSLayoutConstraint!
    
    @IBOutlet weak var invasivePlantsBox: UIView!
    @IBOutlet weak var invasivePlantsLabel: UILabel!
    @IBOutlet weak var invasivePlantsButton: UIButton!
    @IBOutlet weak var invasivePlantsBoxImage: UIImageView!
    @IBOutlet weak var invasivePlantsLowerBar: UIView!
    @IBOutlet weak var invasivePlantsBoxLeft: UIView!
    @IBOutlet weak var invasivePlantsIconLeading: NSLayoutConstraint!
    
    
    @IBOutlet weak var additionalRequirementsBox: UIView!
    @IBOutlet weak var additionalRequirementsLabel: UILabel!
    @IBOutlet weak var additionalRequirementsButton: UIButton!
    @IBOutlet weak var additionalRequirementsImage: UIImageView!
    @IBOutlet weak var additionalRequirementsLowerBar: UIView!
    @IBOutlet weak var additionalRequirementsBoxLeft: UIView!
    @IBOutlet weak var additionalRequirementsIconLeading: NSLayoutConstraint!
    
    @IBOutlet weak var managementBox: UIView!
    @IBOutlet weak var managementLabel: UILabel!
    @IBOutlet weak var managementButton: UIButton!
    @IBOutlet weak var managementBoxImage: UIImageView!
    @IBOutlet weak var managementLowerBar: UIView!
    @IBOutlet weak var managementBoxLeft: UIView!
    @IBOutlet weak var managementIconLeading: NSLayoutConstraint!
    
    /*
     @IBOutlet weak var mapLabel: UILabel!
     @IBOutlet weak var mapButton: UIButton!
     @IBOutlet weak var mapInfoBoxImage: UIImageView!
     */
    
    @IBOutlet weak var submitButtonContainer: UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var requiredFieldNeededLabel: UILabel!
    
    @IBOutlet weak var menuModeButton: UIButton!
    
    // Body
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setMenuSize()
        setUpTable()
        autofill()
        prepareToAnimate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openingAnimations(callBack: {
            // open banner here
            if self.shouldShowBanner() {
                self.openBanner()
            }
            
            let minPlanFieldsMessage = self.minimumPlanFieldsAreFilledMessage()
            if !minPlanFieldsMessage.isEmpty {
                Alert.show(title: "Heads up!", message: minPlanFieldsMessage)
            }
        })
    }
    
    func minimumPlanFieldsAreFilledMessage() -> String {
        guard let plan = self.rup  else {
            return ""
        }
        var message = ""
        if plan.rangeName.isEmpty {
            message = "\(message)Range Name is empty.\n"
        }
        if plan.planStartDate == nil {
            message = "\(message)Plan Start date is empty.\n"
        }
        
        if plan.planEndDate == nil {
             message = "\(message)Plan End date is empty.\n"
        }
        if message.isEmpty {
            return message
        } else {
            let messageDesc = "This plan will not be uploaded untill the minimum fields are filled:\n\n"
            return "\(messageDesc)\(message)"
        }
        
    }
    
    // MARK: Outlet Actions
    @IBAction func menuModeAction(_ sender: UIButton) {
        if self.menuWidth.constant ==  self.portraitMenuWidth {
            styleLandscapeMenu()
        } else {
            stylePortaitMenu()
        }
        animateIt()
    }
    
    @IBAction func bannerTooltipAction(_ sender: UIButton) {
        showTooltip(on: sender, title: getBannerTitle(), desc: getBannerDescription())
    }
    
    @IBAction func planActionActions(_ sender: UIButton) {
        guard let plan = self.rup else {return}
        let planActionsArray = getPlanActions(for: plan)
        let vm = ViewManager()
        let lookup = vm.lookup
        var lookupOptions: [SelectionPopUpObject] = [SelectionPopUpObject]()
        for element in planActionsArray {
            let elementName = "\(element)"
            lookupOptions.append(SelectionPopUpObject(display: elementName.convertFromCamelCase()))
        }
        
        lookup.setup(objects: lookupOptions, onVC: self, onButton: planActionsDropdownButton) {  (done, selected) in
            if let selectedAction = selected, let action = self.getPlanAction(fromString: selectedAction.display) {
                switch action {
                case .UpdateAmendment:
                    self.showAmendmentFlow()
                case .ApproveAmendment:
                    self.showAmendmentFlow()
                case .FinalReview:
                    self.showAmendmentFlow()
                case .UpdateStatus:
                    self.showAmendmentFlow()
                case .CreateMandatoryAmendment:
                    self.createMandatoryAmendment()
                case .CancelAmendment:
                    self.cancelAmendment()
                case .PrepareForSubmission:
                    self.showAmendmentSubmissionFlow()
                case .ReturnToAgreementHolder:
                    // TODO: HERE!!!
                    break
                }
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
        guard let plan = self.rup else {return}
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
    
    @IBAction func basicInfoAction(_ sender: UIButton) {
        tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
    }
    
    @IBAction func pasturesAction(_ sender: UIButton) {
        tableView.scrollToRow(at: pasturesIndexPath, at: .top, animated: true)
    }
    
    @IBAction func scheduleAction(_ sender: UIButton) {
        tableView.scrollToRow(at: scheduleIndexPath, at: .top, animated: true)
    }
    
    @IBAction func ministersIssuesAction(_ sender: UIButton) {
        tableView.scrollToRow(at: minsterActionsIndexPath, at: .top, animated: true)
    }
    
    @IBAction func invasivePlantsAction(_ sender: UIButton) {
        tableView.scrollToRow(at: invasivePlantsIndexPath, at: .top, animated: true)
    }
    @IBAction func additionalRequirementsAction(_ sender: UIButton) {
        tableView.scrollToRow(at: additionalRequirementsIndexPath, at: .top, animated: true)
    }
    @IBAction func managementAction(_ sender: UIButton) {
        tableView.scrollToRow(at: managementIndexPath, at: .top, animated: true)
    }
    
    /*
     @IBAction func mapAction(_ sender: UIButton) {
     tableView.scrollToRow(at: mapIndexPath, at: .top, animated: true)
     }*/
    
    
    @IBAction func reviewAndSubmitAction(_ sender: UIButton) {
        guard let plan = self.rup else {return}
        do {
            let realm = try Realm()
            try realm.write {
                plan.isNew = false
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        
        let validity = RUPManager.shared.isValid(rup: plan)
        if !validity.0 {
            alert(with: "Plan is invalid", message: validity.1)
            return
        }
        closingAnimations()
        showAlert(title: "Confirm", description: "You will not be able to edit this rup after submission", yesButtonTapped: {
            // Yes tapped
            do {
                let realm = try Realm()
                try realm.write {
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
        
        // Moved - being done after openingAminations
        //        if rup.getStatus() == .Stands {
        //            updateAmendmentEnabled = true
        //        } else {
        //            updateAmendmentEnabled = false
        //        }
        
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
            case .error(_):
                Logger.log(message: "Error in Plan \(r.ranNumber) change.")
            case .change(_):
                 Logger.log(message: "Change observed in plan \(r.ranNumber).")
                self.planIsValid = r.isValid
            case .deleted:
                Logger.log(message: "Plan  \(r.ranNumber) deleted.")
            }
        }
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
        if UIDevice.current.orientation.isPortrait ||  UIDevice.current.orientation.isFlat {
            statusAndagreementHolderLabel.text = "\(p.getStatus())"
        } else {
            statusAndagreementHolderLabel.text = "\(p.getStatus()) | \(holder)"
        }
        
        styleStatus()
        animateIt()
    }
    
    func catchAction(notification:Notification) {
        if !reloading {
            self.tableView.reloadData()
            self.reloading = true
        } else {
            self.reloading = false
        }
    }
    override func whenLandscape() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
        }
        styleLandscapeMenu()
        //        setMenuSize()
        setBarInfoBasedOnOrientation()
    }
    override func whenPortrait() {
        if let indexPath = self.tableView.indexPathsForVisibleRows, indexPath.count > 0 {
            self.tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
        }
        stylePortaitMenu()
        //        setMenuSize()
        setBarInfoBasedOnOrientation()
    }
    
    // MARK: Amendments - Plan Actions
    
    // Get the selected option from popover options displayed results
    // Helper function for re-usable lookup popover
    func getPlanAction(fromString name: String) -> PlanAction? {
        switch name.lowercased() {
        case "update amendment":
            return .UpdateAmendment
        case "approve amendment":
            return .ApproveAmendment
        case "final review":
            return .FinalReview
        case "update status":
            return .UpdateStatus
        case "create mandatory amendment":
            return .CreateMandatoryAmendment
        case "cancel amendment":
            return .CancelAmendment
        case "prepare for submission":
            return .PrepareForSubmission
        case "Return To Agreement Holder":
            return .ReturnToAgreementHolder
        default:
            return nil
        }
    }
    
    /*
     case .UpdateAmendment:
        self.showAmendmentFlow()
     case .ApproveAmendment:
        self.showAmendmentFlow()
     case .FinalReview:
        self.showAmendmentFlow()
     case .UpdateStatus:
        self.showAmendmentFlow()
     case .CreateMandatoryAmendment:
        self.createMandatoryAmendment()
     case .CancelAmendment:
        self.cancelAmendment()
     case .PrepareForSubmission:
        self.showAmendmentSubmissionFlow()
     case .ReturnToAgreementHolder:
        self.
     */
    
    func getPlanActions(for plan: Plan) -> [PlanAction] {
        var returnValue: [PlanAction] = [PlanAction]()
        let current = plan.getStatus()
        
        if current == .Stands {
            returnValue.append(.UpdateAmendment)
            
        } else if current == .SubmittedForFinalDecision{
            returnValue.append(.ApproveAmendment)
            
        } else if current == .SubmittedForReview {
            // TODO: HERE!!!
//            returnValue.append(.) //ReturnToAgreementHolder
            
        } else if current == .RecommendReady {
            returnValue.append(.FinalReview)
            
        } else if current == .Pending {
            // Note: Review is required by staff
            returnValue.append(.UpdateStatus)
            // completed / change requested
            
        } else if current == .Approved {
            returnValue.append(.CreateMandatoryAmendment)
            
        } else if (current == .StaffDraft || current == .LocalDraft) && plan.amendmentTypeId != -1 {
            returnValue.append(.CancelAmendment)
            returnValue.append(.PrepareForSubmission)
        }
        return returnValue
    }
    
    func createMandatoryAmendment() {
        guard let plan = self.rup else {return}
        AutoSync.shared.endListener()
        if let agreement = RUPManager.shared.getAgreement(with: plan.agreementId), let inital = Reference.shared.getAmendmentType(named: "Mandatory Amendment") {
            let new = plan.clone()
            do {
                let realm = try Realm()
                try realm.write {
                    new.importAgreementData(from: agreement)
                    new.amendmentTypeId = inital.id
                    new.isNew = false
                    new.remoteId = -1
                    new.statusId = 0
                    new.statusIdValue = ""
                }
            } catch _ {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
            agreement.add(plan: new)
            RealmRequests.saveObject(object: new)
            new.updateStatus(with: .StaffDraft)
            self.setup(rup: new, mode: .Edit)
            self.tableView.reloadData()
            self.autofill()
        }
    }
    
    func showSubmitBackToAgreementHolderFlow() {
        guard let plan = self.rup else {return}
        let amendmentFlow: AmendmentFlow = UIView.fromNib()
        let mode: AmendmentFlowMode = .ReturnToAgreementHolder
        // display
        amendmentFlow.initialize(mode: mode) { (amendment) in
            if let result = amendment, let newStatus = result.getStatus() {
                // process new status
                plan.updateStatus(with: newStatus)
                self.autofill()
                self.stylePlanActions()
            }
        }
    }
    
    
    func showAmendmentSubmissionFlow() {
        guard let plan = self.rup else {return}
        let amendmentFlow: AmendmentFlow = UIView.fromNib()
        let mode: AmendmentFlowMode = .Create
        // display
        amendmentFlow.initialize(mode: mode) { (amendment) in
            if let result = amendment, let newStatus = result.getStatus() {
                // process new status
                plan.updateStatus(with: newStatus)
                self.autofill()
                self.stylePlanActions()
            }
        }
    }
    
    func cancelAmendment() {
        
    }
    
    func showAmendmentFlow() {
        guard let plan = self.rup else {return}
        let amendmentFlow: AmendmentFlow = UIView.fromNib()
        var mode: AmendmentFlowMode = .Initial
        if let amendmentType = Reference.shared.getAmendmentType(forId: plan.amendmentTypeId) {
            mode = .FinalReview
            if amendmentType.name.lowercased().contains("minor") {
                mode = .Minor
            } else if amendmentType.name.lowercased().contains("mandatory") && plan.getStatus() != .RecommendReady {
                mode = .Mandatory
            }
        }
        
        amendmentFlow.initialize(mode: mode) { (amendment) in
            if let result = amendment, let newStatus = result.getStatus() {
                // process new status
                plan.updateStatus(with: newStatus)
                self.autofill()
                self.stylePlanActions()
            }
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rup == nil {
            return getBasicInfoCell(indexPath: indexPath)
        }
        if let cellType = FromSection(rawValue: Int(indexPath.row)) {
            
            switch cellType {
                
            case .BasicInfo:
                self.basicInformationIndexPath = indexPath
                let cell = getBasicInfoCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .PlanInfo:
                let cell = getPlanInformationCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .AgreementHolders:
                let cell = getAgreementHoldersCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .Usage:
                self.rangeUsageIndexPath = indexPath
                let cell = getRangeUsageCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .Pastures:
                self.pasturesIndexPath = indexPath
                let cell = getPasturesCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .YearlySchedule:
                self.scheduleIndexPath = indexPath
                let cell = getScheduleCell(indexPath: indexPath)
                // passing self reference because cells within this cell's tableview need to call showAlert()
                cell.setup(mode: mode, rup: rup!, parentReference: self)
                return cell
            case .MinistersIssues:
                self.minsterActionsIndexPath = indexPath
                let cell = getMinistersIssuesCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .InvasivePlants:
                self.invasivePlantsIndexPath = indexPath
                let cell = getInvasivePlantsCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .AdditionalRequirements:
                self.additionalRequirementsIndexPath = indexPath
                let cell = getAdditionalRequirementsCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .ManagementConsiderations:
                self.managementIndexPath = indexPath
                let cell = getManagementConsiderationsCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            case .Map:
                let cell = getMapCell(indexPath: indexPath)
                return cell
            }
            
        } else {
            return getMapCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FromSection.allCases.count
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
    
    func reload(at indexPath: IndexPath) {
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
    
    func realod(bottomOf indexPath: IndexPath, then: @escaping() -> Void) {
        reload {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            self.hightlightAppropriateMenuItem()
            return then()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hightlightAppropriateMenuItem()
    }
    
    func hightlightAppropriateMenuItem() {
        if let menuView = self.menuView {
            menuView.highlightAppropriateMenuItem()
        }
    }
}

// MARK: Banner
extension CreateNewRUPViewController {
    func shouldShowBanner() -> Bool {
        guard let plan = self.rup else {return false}
        // TODO: Add criteria here
        return plan.amendmentTypeId != -1
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
    
    func openBanner() {
        self.bannerTitle.text = ""
        self.bannerContainer.backgroundColor = UIColor.white
        self.bannerTitle.textColor = Colors.technical.mainText
        self.bannerTitle.font = Fonts.getPrimaryBold(size: 22)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            self.bannerContainerHeight.constant = 50
            self.view.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration()) {
                self.view.layoutIfNeeded()
                self.bannerTitle.text = self.getBannerTitle()
                self.bannerContainer.backgroundColor = Colors.accent.yellow
                self.styleContainer(view: self.bannerContainer)
                self.bannerTooltip.alpha = 1
            }
        }
    }
    
    func closeBanner() {
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration()) {
            self.bannerContainerHeight.constant = 25
        }
    }
}

// MARK: Details pages
extension CreateNewRUPViewController {
    //    func showSchedule(object: Schedule, completion: @escaping (_ done: Bool) -> Void) {
    //        guard let plan = self.rup, let presenter = self.getPresenter() else {return}
    //        presenter.showScheduleDetails(for: object, in: plan, mode: self.mode)
    //    }
    //
    //    func showPlantCommunity(pasture: Pasture, plantCommunity: PlantCommunity, completion: @escaping (_ done: Bool) -> Void) {
    //        guard let plan = self.rup, let presenter = self.getPresenter() else {return}
    //        presenter.showPlanCommunityDetails(for: plantCommunity, of: pasture, in: plan, mode: self.mode)
    //    }
}
