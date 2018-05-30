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
    let portraitMenuWidth: CGFloat = 156
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
    @IBOutlet weak var ranchNameAndNumberLabel: UILabel!
    @IBOutlet weak var saveToDraftButton: UIButton!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!

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

    @IBOutlet weak var pasturesBox: UIView!
    @IBOutlet weak var pasturesLabel: UILabel!
    @IBOutlet weak var pasturesButton: UIButton!
    @IBOutlet weak var pasturesBoxImage: UIImageView!
    @IBOutlet weak var pasturesLowerBar: UIView!
    @IBOutlet weak var pastureBoxLeft: UIView!

    @IBOutlet weak var scheduleBox: UIView!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var scheduleBoxImage: UIImageView!
    @IBOutlet weak var scheduleLowerBar: UIView!
    @IBOutlet weak var scheduleBoxLeft: UIView!


    /*
    @IBOutlet weak var ministersIssuesLabel: UILabel!
    @IBOutlet weak var ministersIssuesButton: UIButton!
    @IBOutlet weak var ministersIssuesBoxImage: UIImageView!

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

    @IBOutlet weak var reviewAndSubmitLabel: UILabel!
    @IBOutlet weak var reviewAndSubmitButton: UIButton!
    @IBOutlet weak var reviewAndSubmitBoxImage: UIImageView!
    @IBOutlet weak var submitButtonContainer: UIView!
    
    // Body
    @IBOutlet weak var tableView: UITableView!

    // custom popup
    @IBOutlet weak var popupVIew: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupTextField: UITextField!
    @IBOutlet weak var grayScreen: UIView!
    @IBOutlet weak var popupCancelButton: UIButton!
    @IBOutlet weak var popupAddButton: UIButton!
    @IBOutlet weak var popupInputHeight: NSLayoutConstraint!
    
    // MARK: POP UP
    @IBAction func popupCancel(_ sender: Any) {
        if popupCompletion == nil {return}
        popupCompletion!(false, "")
        closePopup()
    }

    @IBAction func popupAdd(_ sender: Any) {
        if popupCompletion == nil {return}
        if let text = popupTextField.text {
            // has value
            if text == "" {
                popupTitle.text = "Please enter a value"
                popupTitle.textColor = UIColor.red
                return
            } else {
                // value is not duplicate
                if popupTakenValues.contains(text) {
                    popupTitle.text = "Duplicate value"
                    popupTitle.textColor = UIColor.red
                    return
                } else {
                    // value is in correct format
                    switch acceptedPopupInput {
                    case .String:
                        popupCompletion!(true, text)
                        closePopup()
                    case .Double:
                        if text.isDouble {
                            popupCompletion!(true, text)
                            closePopup()
                        } else {
                            popupTitle.text = "Invalid value"
                            popupTitle.textColor = UIColor.red
                        }
                    case .Integer:
                        if text.isInt {
                            popupCompletion!(true, text)
                            closePopup()
                        } else {
                            popupTitle.text = "Invalid value"
                            popupTitle.textColor = UIColor.red
                        }
                    case .Year:
                        if text.isInt {
                            let year = Int(text) ?? 0
                            if (year > 2000) && (year < 2100) {
                                popupCompletion!(true, text)
                                closePopup()
                            } else {
                                popupTitle.text = "Invalid Year"
                                popupTitle.textColor = UIColor.red
                            }
                        } else {
                            popupTitle.text = "Invalid value"
                            popupTitle.textColor = UIColor.red
                        }
                    }
                }
            }
        }
    }

    func openPopup() {
        self.tableView.isUserInteractionEnabled = false

        self.grayScreen.alpha = 1
        self.popupVIew.alpha = 1
    }

    func closePopup() {
        self.grayScreen.alpha = 0
        self.popupTextField.text = ""
        self.popupCompletion = nil
        self.popupVIew.alpha = 0
        self.tableView.isUserInteractionEnabled = true
        IQKeyboardManager.sharedManager().resignFirstResponder()
    }
    // end of custom popup

    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setMenuSize()
        closePopup() 
        setUpTable()
        autofill()
        prepareToAnimate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openingAnimations()
    }

    // MARK: Outlet Actions
    @IBAction func saveToDraftAction(_ sender: UIButton) {
        guard let plan = self.rup else {return}
        do {
            let realm = try Realm()
            try realm.write {
                plan.isNew = false
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

    /*
    @IBAction func ministersIssuesAction(_ sender: UIButton) {
    }
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
            self.openingAnimations()
        }
    }

    // MARK: Functions
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
                    self.rup?.statusEnum = .Draft
                }
            } catch _ {
                fatalError()
            }
        }

        setUpTable()

        self.realmNotificationToken = rup.observe { (change) in
            switch change {
            case .error(_):
                print("Error in rup change")
            case .change(_):
                self.planIsValid = rup.isValid
            case .deleted:
                print("RUP deleted")
            }
        }
    }

    func autofill() {
        let num = rup?.agreementId ?? ""
        let name = rup?.rangeName ?? ""
        ranchNameAndNumberLabel.text = "\(num) | \(name)"
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
    }
    override func whenPortrait() {
        setMenuSize()
    }

}

// MARK: Tableview
extension CreateNewRUPViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil {return}
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updateTableHeights, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
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

    func realodAndGoTo(indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.tableView.layoutIfNeeded()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func deepReload(indexPath: IndexPath) {
        self.tableView.reloadData()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPaths = self.tableView.indexPathsForVisibleRows, indexPaths.count > 0 {
            var indexPath = indexPaths[0]
            if indexPaths.count > 1 {
                indexPath = indexPaths[1]
            }
          if indexPaths.count > 2 {
               indexPath = indexPaths[2]
           }
          if indexPath == basicInformationIndexPath || indexPath ==  rangeUsageIndexPath {
               menuBasicInfoOn()
           } else if indexPath == pasturesIndexPath {
               menuPastureOn()
           } else if indexPath == scheduleIndexPath {
              menuScheduleOn()
          }
      }
  }
}

// MARK: Input Prompt
extension CreateNewRUPViewController {
    // Use done variable in completion to indicate if user cancelled or not
    func promptInput(title: String, accept: AcceptedPopupInput,taken: [String],completion: @escaping (_ done: Bool,_ result: String) -> Void) {
        self.acceptedPopupInput = accept
        self.popupTakenValues = taken
        self.popupTitle.text = title
        self.popupCompletion = completion
        self.popupTitle.textColor = UIColor.black
        self.openPopup()
    }
}

// MARK: Schedule View
extension CreateNewRUPViewController {
    func showSchedule(object: Schedule, completion: @escaping (_ done: Bool) -> Void) {
         let vm = ViewManager()
        let schedule = vm.schedule
        schedule.setup(mode: mode, rup: rup!, schedule: object, completion: completion)
        self.present(schedule, animated: true, completion: nil)
    }
}
