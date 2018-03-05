//
//  CreateNewRUPViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class CreateNewRUPViewController: UIViewController {

    // Mark: Variables

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
//    var rangeUseYears: [RangeUsageYear] = [RangeUsageYear]()
//    var pastures: [Pasture] = [Pasture]() {
//        didSet{
//            updateSubtableHeights()
//        }
//    }
//    var agreementHolders: [AgreementHolder] = [AgreementHolder]()
//    var liveStockIDs: [LiveStockID] = [LiveStockID]()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setDummy()
        setUpTable()
        setMenuSize()
        if !reloaded {
            updateSubtableHeights()

        }

        NotificationCenter.default.addObserver(forName: .updatePastureCells, object: nil, queue: nil, using: catchAction)
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
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func basicInfoAction(_ sender: UIButton) {
        tableView.scrollToRow(at: basicInformationIndexPath, at: .top, animated: true)
    }
    @IBAction func pasturesAction(_ sender: UIButton) {
        tableView.scrollToRow(at: pasturesIndexPath, at: .top, animated: true)
    }
    @IBAction func scheduleAction(_ sender: UIButton) {
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
    }

    // Mark: Functions
    func getMapVC() -> CreateViewController {
        return ViewManager.shared.create
    }

    func setDummy() {
//        self.rangeUseYears = DummySupplier.shared.getRangeUseYears(count: 1)
//        self.pastures = DummySupplier.shared.getPastures(count: 1)
//        self.agreementHolders = DummySupplier.shared.getAgreementHolders(count: 1)
//        self.liveStockIDs = DummySupplier.shared.getLiveStockIDs(count: 1)
        self.rup = RUP()
        self.rup?.id = "RUPID"
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
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updateTableHeights, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "BasicInformationTableViewCell")
        registerCell(name: "AgreementInformationTableViewCell")
        registerCell(name: "LiveStockIDTableViewCell")
        registerCell(name: "RangeUsageTableViewCell")
        registerCell(name: "PasturesTableViewCell")
        registerCell(name: "MapTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getRangeUsageCell(indexPath: IndexPath) -> RangeUsageTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "RangeUsageTableViewCell", for: indexPath) as! RangeUsageTableViewCell
    }

    func getBasicInfoCell(indexPath: IndexPath) -> BasicInformationTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "BasicInformationTableViewCell", for: indexPath) as! BasicInformationTableViewCell
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

    func getMapCell(indexPath: IndexPath) -> MapTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row

        // this will change. some indexes will be unknown at compile time
        switch index {
        case 0:
            self.basicInformationIndexPath = indexPath
            return getBasicInfoCell(indexPath: indexPath)
        case 1:
            self.rangeUsageIndexPath = indexPath
            let cell = getRangeUsageCell(indexPath: indexPath)
            cell.setup(mode: mode, rangeUsageYears: (rup?.rangeUsageYears)!)
            return cell
        case 2:
            self.agreementInformationIndexPath = indexPath
            let cell = getAgreementInformationCell(indexPath: indexPath)
            cell.setup(mode: mode, agreementHolders: (rup?.agreementHolders)!)
            return cell
        case 3:
            self.liveStockIDIndexPath = indexPath
            let cell = getLiveStockIDTableViewCell(indexPath: indexPath)
            cell.setup(mode: mode, liveStockIDs: (rup?.liveStockIDs)!)
            return cell
        case 4:
            self.pasturesIndexPath = indexPath
            let cell = getPasturesCell(indexPath: indexPath)
            cell.setup(mode: mode, pastures: (rup?.pastures)!)
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
        print(indexPath)
        self.tableView.reloadData()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func deepReload(indexPath: IndexPath) {
        self.tableView.reloadData()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

}
