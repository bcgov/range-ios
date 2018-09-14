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

enum FromSection: Int {
    case BasicInfo = 0
    case PlanInfo
    case AgreementHolders
    case Usage
    case Pastures
    case YearlySchedule
    case MinistersIssues
}

class CreateNewRUPViewController: BaseViewController {

    // MARK: Constants
    let landscapeMenuWidh: CGFloat = 265
    let portraitMenuWidth: CGFloat = 64
    let numberOfSections = 7

    // MARK: Variables
    var parentCallBack: ((_ close: Bool, _ cancel: Bool) -> Void )?

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

    var rup: RUP?

    var updateAmendmentEnabled = false

    var copy: RUP?

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
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var ranLabel: UILabel!

    @IBOutlet weak var statusLight: UIView!

    @IBOutlet weak var statusAndagreementHolderLabel: UILabel!

    @IBOutlet weak var saveToDraftButton: UIButton!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var updateAmendmentButton: UIButton!

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

    /*

    @IBOutlet weak var invasivePlantsLabel: UILabel!
    @IBOutlet weak var invasivePlantsButton: UIButton!
    @IBOutlet weak var invasivePlantsBoxImage: UIImageView!

    @IBOutlet weak var additionalRequirementsLabel: UILabel!
    @IBOutlet weak var additionalRequirementsButton: UIButton!
    @IBOutlet weak var additionalRequirementsBoxImage: UIImageView!

    @IBOutlet weak var managementLabel: UILabel!
    @IBOutlet weak var managementButton: UIButton!
    @IBOutlet weak var managementBoxImage: UIImageView!

    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapInfoBoxImage: UIImageView!
    */

    @IBOutlet weak var submitButtonContainer: UIView!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var requiredFieldNeededLabel: UILabel!

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
        })
    }

    // MARK: Outlet Actions
    @IBAction func bannerTooltipAction(_ sender: UIButton) {
        showTooltip(on: sender, title: getBannerTitle(), desc: getBannerDescription())
    }

    @IBAction func updateAmendmentAction(_ sender: UIButton) {
        guard let plan = self.rup, let amendmentType = Reference.shared.getAmendmentType(forId: plan.amendmentTypeId) else {return}

        // get flow view controller
        let vm = ViewManager()
        let flow = vm.amendmentFlow

        // select mode
        var mode: AmendmentFlowMode = .FinalReview
        if amendmentType.name.lowercased().contains("minor") {
            mode = .Minor
        } else if amendmentType.name.lowercased().contains("mandatory") && plan.getStatus() != .RecommendReady {
            mode = .Mandatory
        }

        // display
        flow.display(on: self, mode: mode) { (amendment) in
            if let result = amendment, let newStatus = result.getStatus() {
                // process new status
                plan.updateStatus(with: newStatus)
                self.autofill()
                self.styleUpdateAmendmentButton()
            }
        }
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        if let new: RUP = self.copy, let old: RUP = self.rup {

            // If is not new (not just created from agreement)
            // Store the copy created before changes.
            if !old.isNew {
                // save copy
                RealmRequests.saveObject(object: new)

                //  add plan to appropriate agreement
                let agreement = RUPManager.shared.getAgreement(with: new.agreementId)
                do {
                    let realm = try Realm()
                    try realm.write {
                        agreement?.rups.append(new)
                    }
                } catch _ {
                    fatalError()
                }
                // remove modified RUP object
                old.deleteEntries()
                RealmRequests.deleteObject(old)
            }
            // ELSE it you came here from agreement selection, and changed your mind.
            // dont store any rup

            // Dismiss view controller
            self.dismiss(animated: true) {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true, true)
                }
            }
        }
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
                fatalError()
            }

            RealmRequests.updateObject(plan)

            self.dismiss(animated: true) {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true, false)
                }
            }
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
    /*
    @IBAction func invasivePlantsAction(_ sender: UIButton) {
    }
    @IBAction func additionalRequirementsAction(_ sender: UIButton) {
    }
    @IBAction func managementAction(_ sender: UIButton) {
    }
    @IBAction func mapAction(_ sender: UIButton) {
        tableView.scrollToRow(at: mapIndexPath, at: .top, animated: true)
    }
    */

    @IBAction func reviewAndSubmitAction(_ sender: UIButton) {
        guard let plan = self.rup else {return}
        do {
            let realm = try Realm()
            try realm.write {
                plan.isNew = false
            }
        } catch _ {
            fatalError()
        }

        let validity = RUPManager.shared.isValid(rup: plan)
        if !validity.0 {
            showAlert(with: "Plan is invalid", message: validity.1)
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
            // Dismiss view controller
            self.dismiss(animated: true) {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true, false)
                }
            }
        }) {
            // No tapped
            self.openingAnimations(callBack: {
                // TODO: Open banner if needed
            })
        }
    }

    // MARK: Functions
    func refreshPlanObject() {
        guard let plan = self.rup else {return}
        do {
            let realm = try Realm()
            let aRup = realm.objects(RUP.self).filter("localId = %@", plan.localId).first!
            self.rup = aRup
        } catch _ {
            fatalError()
        }
    }

    // MARK: Setup
    func setup(rup: RUP, mode: FormMode, callBack: @escaping ((_ close: Bool, _ cancel: Bool) -> Void )) {
        self.parentCallBack = callBack
        self.rup = rup
        self.mode = mode
        self.copy = nil

        switch mode {
        case .View:
            break
        case .Edit:
            /*
             Create copy.
             If cancel is pressed, store copy and delete rup
             Otherwise don't save the Plan copy object.
             */
            self.copy = rup.copy()
            do {
                let realm = try Realm()
                try realm.write {
                    self.rup?.statusEnum = .LocalDraft
                }
            } catch _ {
                fatalError()
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
        self.realmNotificationToken = r.observe { (change) in
            switch change {
            case .error(_):
                print("Error in rup change")
            case .change(_):
                self.planIsValid = r.isValid
            case .deleted:
                print("RUP deleted")
            }
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
        highlightCurrentModuleInMenu()
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
        setMenuSize()
        setBarInfoBasedOnOrientation()
    }
    override func whenPortrait() {
        setMenuSize()
        setBarInfoBasedOnOrientation()
    }

}

// MARK: Tableview
extension CreateNewRUPViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil {return}
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updateTableHeights, object: nil)
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

    func getMapCell(indexPath: IndexPath) -> MapTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
                self.minsterActionsIndexPath = indexPath
                let cell = getMinistersIssuesCell(indexPath: indexPath)
                cell.setup(mode: mode, rup: rup!)
                return cell
            }

        } else {
            return getMapCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfSections
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
                self.highlightCurrentModuleInMenu()
                return then()
            })
        } else {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.layoutIfNeeded()
            self.highlightCurrentModuleInMenu()
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
            self.highlightCurrentModuleInMenu()
            return then()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        highlightCurrentModuleInMenu()
    }

    func highlightCurrentModuleInMenu() {
        if let indexPaths = self.tableView.indexPathsForVisibleRows, indexPaths.count > 0 {
            // select the first indexPath
            var indexPath = indexPaths[0]

            // If there are 3 or more visible cells, pick the middle
            if indexPaths.count > 1 {
                let count = indexPaths.count
                indexPath = indexPaths[count/2]
            }

            // if there are 2 visible cells, find the most visible
            if indexPaths.count == 2 {
                let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
                let visiblePoint = CGPoint(x:visibleRect.midX, y:visibleRect.midY)
                if let i = tableView.indexPathForRow(at: visiblePoint) {
                    indexPath = i
                }
            }

            // Switch it on
            if indexPath == basicInformationIndexPath || indexPath ==  rangeUsageIndexPath {
                menuBasicInfoOn()
            } else if indexPath == pasturesIndexPath {
                menuPastureOn()
            } else if indexPath == scheduleIndexPath {
                menuScheduleOn()
            } else if indexPath == minsterActionsIndexPath {
                menuMinistersIssuesOn()
            }
        }
    }
}

// MARK: Banner
extension CreateNewRUPViewController {
    func shouldShowBanner() -> Bool {
        guard let plan = self.rup else {return false}
        // TODO: Add criteria here
        return (plan.getStatus() != .LocalDraft && plan.getStatus() != .StaffDraft)
    }

    func getBannerTitle() -> String {
        return bannerMinorAmendmentReviewRequiredTitle
    }

    func getBannerDescription() -> String {
        return bannerMinorAmendmentReviewRequiredDescription
    }

    func openBanner() {
        self.bannerTitle.text = ""
        self.bannerContainer.backgroundColor = UIColor.white
        self.bannerTitle.textColor = Colors.technical.mainText
        self.bannerTitle.font = Fonts.getPrimaryBold(size: 22)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, animations: {
            self.bannerContainerHeight.constant = 50
            self.view.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.bannerTitle.text = self.getBannerTitle()
                self.bannerContainer.backgroundColor = Colors.accent.yellow
                self.styleContainer(view: self.bannerContainer)
                self.bannerTooltip.alpha = 1
            }
        }
    }

    func closeBanner() {
        UIView.animate(withDuration: 0.4) {
            self.bannerContainerHeight.constant = 25
        }
    }
}

// MARK: Details pages
extension CreateNewRUPViewController {
    func showSchedule(object: Schedule, completion: @escaping (_ done: Bool) -> Void) {
        guard let plan = self.rup else {return}
        AutoSync.shared.endListener()
        let vm = ViewManager()
        let schedule = vm.schedule
        schedule.setup(mode: mode, rup: plan, schedule: object, completion: { done in
            AutoSync.shared.beginListener()
            completion(done)
        })
        self.present(schedule, animated: true, completion: nil)
    }

    func showPlantCommunity(pasture: Pasture, plantCommunity: PlantCommunity, completion: @escaping (_ done: Bool) -> Void) {
        guard let plan = self.rup else {return}
        AutoSync.shared.endListener()
        let vm = ViewManager()
        let plantCommunityDetails = vm.plantCommunity
        plantCommunityDetails.setup(mode: mode, plan: plan, pasture: pasture, plantCommunity: plantCommunity, completion: { done in
            AutoSync.shared.beginListener()
            completion(done)
        })
        self.present(plantCommunityDetails, animated: true, completion: nil)
    }
}
