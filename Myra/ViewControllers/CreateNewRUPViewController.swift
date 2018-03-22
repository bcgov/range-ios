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

class CreateNewRUPViewController: UIViewController {

    // Mark: Variables

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

    var reloaded: Bool = false

    // MARK: Outlets

    // TOP
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var ranchNameAndNumberLabel: UILabel!
    @IBOutlet weak var saveToDraftButton: UIButton!

    // Side Menu
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var menuLeading: NSLayoutConstraint!
    
    @IBOutlet weak var basicInfoLabel: UILabel!
    @IBOutlet weak var basicInfoButton: UIButton!
    @IBOutlet weak var basicInfoBoxImage: UIImageView!

    @IBOutlet weak var pasturesLabel: UILabel!
    @IBOutlet weak var pasturesButton: UIButton!
    @IBOutlet weak var pasturesBoxImage: UIImageView!

    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var scheduleBoxImage: UIImageView!

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

    @IBOutlet weak var reviewAndSubmitLabel: UILabel!
    @IBOutlet weak var reviewAndSubmitButton: UIButton!
    @IBOutlet weak var reviewAndSubmitBoxImage: UIImageView!

    // Body
    @IBOutlet weak var tableView: UITableView!

    // custom popup
    @IBOutlet weak var popupVIew: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupTextField: UITextField!
    @IBOutlet weak var grayScreen: UIView!
    var acceptedPopupInput: AcceptedPopupInput = .String
    var popupCompletion: ((_ done: Bool,_ result: String) -> Void )?
    var popupTakenValues: [String] = [String]()

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


    override func viewDidLoad() {
        super.viewDidLoad()
//        setDummy()
        closePopup() 
        setUpTable()
        setMenuSize()
        if !reloaded {
            updateSubtableHeights()
        }

        NotificationCenter.default.addObserver(forName: .updatePastureCells, object: nil, queue: nil, using: catchAction)
        autofill()
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

    // Mark: Outlet Actions
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
    @IBAction func reviewAndSubmitAction(_ sender: UIButton) {
        APIManager.send(rup: self.rup!) { (done) in
            if done {
//                self.parentVC?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
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

    func setDummy() {
        self.rup = RUP()
        self.rup?.id = 0
        let basicInfo = BasicInformation()
        self.rup?.basicInformation = basicInfo
    }

    func updateSubtableHeights() {
        NotificationCenter.default.post(name: .updateTableHeights, object: self, userInfo: ["reload": true])
    }

}

extension CreateNewRUPViewController {
    // TODO: currently unused. reposition loading spinner.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setMenuSize()
        }
    }

    func setMenuSize() {
        if UIDevice.current.orientation.isLandscape{
            self.menuWidth.constant = 265
            self.animateIt()
        } else {
            self.menuWidth.constant = 156
            self.animateIt()
        }
    }
}

extension CreateNewRUPViewController {
    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func animateFor(time: Double) {
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

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

    func getAgreementInformationCell(indexPath: IndexPath) -> AgreementInformationTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AgreementInformationTableViewCell", for: indexPath) as! AgreementInformationTableViewCell
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
            cell.setup(mode: mode, rup: rup!)
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
        case 3:
            self.liveStockIDIndexPath = indexPath
            let cell = getLiveStockIDTableViewCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!)
            return cell
        case 4:
            self.pasturesIndexPath = indexPath
            let cell = getPasturesCell(indexPath: indexPath)
            cell.setup(mode: mode, rup: rup!)
            return cell
        case 5:
            self.scheduleIndexPath = indexPath
            let cell = getScheduleCell(indexPath: indexPath)
            cell.setup(rup: rup!)
            return cell
        default:
            self.mapIndexPath = indexPath
            return getMapCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func realodAndGoTO(indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func deepReload(indexPath: IndexPath) {
        self.tableView.reloadData()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

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

extension CreateNewRUPViewController {
    func showSchedule(object: Schedule) {
         let vm = ViewManager()
        let schedule = vm.schedule
        schedule.setup(rup: rup!, schedule: object)
//        schedule.schedule = object
        self.present(schedule, animated: true, completion: nil)
    }
}
