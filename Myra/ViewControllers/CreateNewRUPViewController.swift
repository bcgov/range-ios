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

enum AcceptedPopupInput {
    case String
    case Double
    case Integer
    case Year
}

class CreateNewRUPViewController: BaseViewController {

    // MARK: Constants
    let landscapeMenuWidh: CGFloat = 265
    let horizontalMenuWidth: CGFloat = 156

    // MARK: Variables
    var parentCallBack: ((_ close: Bool) -> Void )?

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

    var reloading: Bool = false

    var mode: FormMode = .Create

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
        self.grayScreen.alpha = 0.8
        self.popupVIew.alpha = 1
    }

    func closePopup() {
        self.grayScreen.alpha = 0
        self.popupTextField.text = ""
        self.popupCompletion = nil
        self.popupVIew.alpha = 0
        self.tableView.isUserInteractionEnabled = true
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

    // MARK: Setup
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

    // MARK: Outlet Actions
    @IBAction func saveToDraftAction(_ sender: UIButton) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup?.statusEnum = .Draft
            }
        } catch _ {
            fatalError()
        }
        RealmRequests.updateObject(self.rup!)
        self.dismiss(animated: true) {
            if self.parentCallBack != nil {
                return self.parentCallBack!(true)
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

    @IBAction func reviewAndSubmitAction(_ sender: UIButton) {
        closingAnimations()
        showAlert(title: "Confirm", description: "You will not be able to edit this rup after submission", yesButtonTapped: {
            // Yes tapped
            do {
                let realm = try Realm()
                try realm.write {
                    self.rup?.statusEnum = .Outbox
                }
                
            } catch _ {}
            // Dismiss view controller
            self.dismiss(animated: true) {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true)
                }
            }
        }) {
            // No tapped
            self.openingAnimations()
        }
    }

    // Mark: Functions
    func getMapVC() -> CreateViewController {
        let vm = ViewManager()
        return vm.create
    }

    func setup(rup: RUP, callBack: @escaping ((_ close: Bool) -> Void )) {
        self.parentCallBack = callBack
        self.rup = rup
        do {
            let realm = try Realm()
            try realm.write {
                self.rup?.statusEnum = .Draft
            }
        } catch _ {
            fatalError()
        }
        setUpTable()
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
//        registerCell(name: "BasicInformationTableViewCell")
        registerCell(name: "BasicInfoTableViewCell")
        registerCell(name: "BasicInfoSectionTwoTableViewCell")
        registerCell(name: "AgreementInformationTableViewCell")
        registerCell(name: "LiveStockIDTableViewCell")
        registerCell(name: "RangeUsageTableViewCell")
        registerCell(name: "PasturesTableViewCell")
        registerCell(name: "MapTableViewCell")
        registerCell(name: "ScheduleTableViewCell")
    }

    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getRangeUsageCell(indexPath: IndexPath) -> RangeUsageTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "RangeUsageTableViewCell", for: indexPath) as! RangeUsageTableViewCell
    }

    func getBasicInfoSectionTwoCell(indexPath: IndexPath) -> BasicInfoSectionTwoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "BasicInfoSectionTwoTableViewCell", for: indexPath) as! BasicInfoSectionTwoTableViewCell
    }

    func getBasicInfoCell(indexPath: IndexPath) -> BasicInfoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "BasicInfoTableViewCell", for: indexPath) as! BasicInfoTableViewCell
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

    func getMapCell(indexPath: IndexPath) -> MapTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row

        // this will change. some indexes will be unknown at compile time
        switch index {
        case 0:
            self.basicInformationIndexPath = indexPath
            let cell = getBasicInfoCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!, parentReference: self)
            return cell
        case 1:
            let cell = getBasicInfoSectionTwoCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!)
            return cell
        case 2:
            self.rangeUsageIndexPath = indexPath
            let cell = getRangeUsageCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!)
            return cell
//        case 3:
//            self.liveStockIDIndexPath = indexPath
//            let cell = getLiveStockIDTableViewCell(indexPath: indexPath)
//            cell.setup(mode: mode, rup: rup!)
//            return cell
        case 3:
            self.pasturesIndexPath = indexPath
            let cell = getPasturesCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!)
            return cell
        case 4:
            self.scheduleIndexPath = indexPath
            let cell = getScheduleCell(indexPath: indexPath)
            // passing self reference because cells within this cell's tableview need to call showAlert()
            cell.setup(rup: rup!, parentReference: self)
            return cell
        default:
            self.mapIndexPath = indexPath
            return getMapCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func realodAndGoTO(indexPath: IndexPath) {
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
        schedule.setup(rup: rup!, schedule: object, completion: completion)
        self.present(schedule, animated: true, completion: nil)
    }
}
