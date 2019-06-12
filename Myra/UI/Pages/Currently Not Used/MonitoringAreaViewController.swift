//
//  MonitoringAreaViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MonitoringAreaViewController: BaseViewController {

    // MARK: Variables
    var completion: ((_ done: Bool) -> Void)?
    var monitoringArea: MonitoringArea?
    var plantCommunity: PlantCommunity?
    var mode: FormMode = .View
    var plan: Plan?

    // MARK: Outlets
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var navbar: UIView!
    @IBOutlet weak var statusbar: UIView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var navbarTitle: UILabel!

    @IBOutlet weak var bannerLabel: UILabel!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var banner: UIView!

    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setTitle()
        setSubtitle()
        style()
    }

    // MARK: Outlet Actions
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if let callback = self.completion {
                return callback(true)
            }
        })
    }

//    @IBAction func deleteAction(_ sender: Any) {
//        guard let ma = self.monitoringArea else{ return }
//        showAlert(title: "Would you like to delete this Monitoring Area?", description: "all data entered on this page will be lost", yesButtonTapped: {
//            RealmManager.shared.deleteMonitoringArea(object: ma)
//            self.dismiss(animated: true, completion: {
//                if let callback = self.completion {
//                    return callback(true)
//                }
//            })
//        }, noButtonTapped: {})
//    }

    // MARK: Setup
    func setup(mode: FormMode, plan: Plan, plantCommunity: PlantCommunity, monitoringArea: MonitoringArea, completion: @escaping (_ done: Bool) -> Void) {
        self.monitoringArea = monitoringArea
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.completion = completion
        self.plan = plan
        setUpTable()
        setTitle()
        setSubtitle()
    }

    func setTitle() {
        if self.pageTitle == nil {return}
        guard let ma = self.monitoringArea else {return}
        self.pageTitle.text = "Monitoring Area: \(ma.name)"
    }

    func setSubtitle() {
        if self.subtitle == nil { return }
        guard let pc = self.plantCommunity else {return}
        self.subtitle.text = pc.name
    }

    // MARK: Styles
    func style() {
        styleNavBar(title: navbarTitle, navBar: navbar, statusBar: statusbar, primaryButton: backbutton, secondaryButton: nil, textLabel: nil)
        styleHeader(label: pageTitle)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
        styleHollowButton(button: saveButton)
    }

    // MARK: Banner
    func openBanner(message: String) {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.bannerLabel.textColor = Colors.primary
            self.banner.backgroundColor = Colors.secondaryBg.withAlphaComponent(1)
            self.bannerHeight.constant = 50
            self.bannerLabel.text = message
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
                    self.bannerLabel.textColor = Colors.primaryConstrast
                    self.view.layoutIfNeeded()
                })
            })
        }
    }

    func closeBanner() {
        self.bannerHeight.constant = 0
        animateIt()
    }

    func refreshMonitoringAreaObject() {
        guard let a = monitoringArea else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(MonitoringArea.self).filter("localId = %@", a.localId).first!
            self.monitoringArea = temp
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }

    func reload(then: @escaping() -> Void) {
        refreshMonitoringAreaObject()
        if #available(iOS 11.0, *) {
            self.tableView.performBatchUpdates({
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }, completion: { done in
                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                return then()
            })
        } else {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.view.layoutIfNeeded()
            return then()
        }
    }
}

// MARK: Tableview
extension MonitoringAreaViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self

        registerCell(name: "MonitoringAreaBasicInfoTableViewCell")
        registerCell(name: "MonitoringAreaCustomDetailsTableViewCell")

        let nib = UINib(nibName: "CustomSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getBasicInfoCell(indexPath: IndexPath) -> MonitoringAreaBasicInfoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MonitoringAreaBasicInfoTableViewCell", for: indexPath) as! MonitoringAreaBasicInfoTableViewCell
    }

    func getPlantIndicatorCell(indexPath: IndexPath) -> MonitoringAreaCustomDetailsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MonitoringAreaCustomDetailsTableViewCell", for: indexPath) as! MonitoringAreaCustomDetailsTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let ma = self.monitoringArea else {return getBasicInfoCell(indexPath: indexPath)}
        switch indexPath.section {
        case 0:
            let cell = getBasicInfoCell(indexPath: indexPath)
//            cell.setup(mode: mode, monitoringArea: ma, parentReference: self)
            return cell
//        case 1:
//            let cell = getPlantIndicatorCell(indexPath: indexPath)
//            cell.setup(section: .RangeReadiness, mode: mode, area: ma, parentReference: self)
//            return cell
//        case 2:
//            let cell = getPlantIndicatorCell(indexPath: indexPath)
//            cell.setup(section: .StubbleHeight, mode: mode, area: ma, parentReference: self)
//            return cell
//        case 3:
//            let cell = getPlantIndicatorCell(indexPath: indexPath)
//            cell.setup(section: .ShrubUse, mode: mode, area: ma, parentReference: self)
//            return cell
        default:
            return getBasicInfoCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionTitle = ""
        switch section {
        case 0:
            sectionTitle =  "Basic Monitoring Area Information"
        case 1:
            sectionTitle =  ""
        case 2:
            sectionTitle =  ""
        default:
            sectionTitle =  ""
        }

        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader")
        let header = cell as! CustomSectionHeader
        header.setup(title: sectionTitle, buttonCallback: {})

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
