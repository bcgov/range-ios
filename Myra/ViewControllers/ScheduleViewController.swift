//
//  ScheduleViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleViewController: BaseViewController {

    // MARK: Variables
    var completion: ((_ done: Bool) -> Void)?
    var footerReference: ScheduleFooterTableViewCell?
    var schedule: Schedule?
    var rup: RUP?
    var mode: FormMode = .View
    var popupContainerTag = 200
    var popover: UIPopoverPresentationController?

    var realmNotificationToken: NotificationToken?

    // MARK: Outlets
    @IBOutlet weak var scheduleTitle: UILabel!
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

    

    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: (rup?.agreementId)!, agreementHolder: "", rangeName: (rup?.rangeName)!)
        style()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validate()
    }

    // MARK: Outlet Actions
    @IBAction func backAction(_ sender: UIButton) {
        if let r = self.rup {
            RealmRequests.updateObject(r)
        }

        self.dismiss(animated: true, completion: {
            if let callback = self.completion {
                return callback(true)
            }
//            return self.completion!(true)
        })
    }

    // MARK: Setup
    func setup(mode: FormMode, rup: RUP, schedule: Schedule, completion: @escaping (_ done: Bool) -> Void) {
        self.rup = rup
        self.mode = mode
        self.schedule = schedule
        self.completion = completion
        let scheduleObjects = schedule.scheduleObjects
        for object in scheduleObjects {
            RUPManager.shared.calculateScheduleEntry(scheduleObject: object)
        }
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: rup.agreementId, agreementHolder: "", rangeName: rup.rangeName)

        self.realmNotificationToken = schedule.observe { (change) in
            switch change {
            case .error(_):
                print("Error in rup change")
            case .change(_):
                self.validate()
            case .deleted:
                print("RUP deleted")
            }
        }
    }

    func setTitle() {
        if self.scheduleTitle == nil { return }
        if schedule == nil {return}
        if let scheduleName = schedule?.name {
            self.scheduleTitle.text = "\(scheduleName) Grazing Schedule"
        }
    }

    func setSubtitle(ranNumber: String, agreementHolder: String, rangeName: String) {
        if self.subtitle == nil { return }
        self.subtitle.text = "\(ranNumber) | \(rangeName)"
    }

    // MARK: Livestock selection popup
    func getLiveStockPopupHolder() -> UIView {
        let layerWidth: CGFloat = (self.view.frame.width / 4)
        let layerHeight: CGFloat = (self.view.frame.height / 2)
        let layer = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: layerWidth, height: layerHeight))
        layer.layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white
        layer.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 10
        layer.center.x = self.view.center.x
        layer.center.y = self.view.center.y
        layer.tag = popupContainerTag
        return layer
    }

    func rotatePopup() {
        if let whiteBG = self.view.viewWithTag(whiteScreenTag), let container = self.view.viewWithTag(popupContainerTag) {
            whiteBG.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            whiteBG.center.y = self.view.center.y
            whiteBG.center.x = self.view.center.x

            let containerWidth: CGFloat = (self.view.frame.width / 4)
            let containerHeight: CGFloat = (self.view.frame.height / 2)

            container.frame.size.width = containerWidth
            container.frame.size.height = containerHeight
            container.center.y = self.view.center.y
            container.center.x = self.view.center.x
        }
    }

    // MARK: Event handlers
    override func whenLandscape() {
        rotatePopup()
    }

    override func whenPortrait() {
        rotatePopup()
    }

    func reload(then: @escaping()-> Void) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.view.layoutIfNeeded()
        return then()
    }

    func calculateTotals() {
        guard let footer = footerReference else {return}
        footer.autofill()
    }

    // MARK: Styles
    func style() {
        styleNavBar(title: navbarTitle, navBar: navbar, statusBar: statusbar, primaryButton: backbutton, secondaryButton: nil, textLabel: nil)
        styleHeader(label: scheduleTitle)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
    }

    // MARK: Banner
    func openBanner(message: String) {
        UIView.animate(withDuration: shortAnimationDuration, animations: {
            self.bannerLabel.textColor = Colors.primary
            self.banner.backgroundColor = Colors.secondaryBg.withAlphaComponent(1)
            self.bannerHeight.constant = 50
            self.bannerLabel.text = message
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: self.mediumAnimationDuration, animations: {
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

    // MARK: Validation
    func validate() {
        guard let current = schedule, let plan = rup else {return}
        let valid = RUPManager.shared.validateSchedule(schedule: current, agreementID: plan.agreementId)
        if !valid.0 {
            openBanner(message: valid.1)
        } else {
            closeBanner()
        }
    }

    func highlightBanner() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bannerLabel.textColor = Colors.primary.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bannerLabel.textColor = Colors.primary.withAlphaComponent(1)
                    self.view.layoutIfNeeded()
                })
            })
        }
    }
}

// MARK: Tableview
extension ScheduleViewController:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleFormTableViewCell")
        registerCell(name: "ScheduleFooterTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleCell(indexPath: IndexPath) -> ScheduleFormTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleFormTableViewCell", for: indexPath) as! ScheduleFormTableViewCell
    }

    func getScheduleFooterCell(indexPath: IndexPath) -> ScheduleFooterTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleFooterTableViewCell", for: indexPath) as! ScheduleFooterTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = getScheduleCell(indexPath: indexPath)
            cell.setup(mode: mode, schedule: schedule!, rup: rup!, parentReference: self)
            return cell
        case 1:
            let cell = getScheduleFooterCell(indexPath: indexPath)
            cell.setup(mode: mode, schedule: schedule!, agreementID: (rup?.agreementId)!)
            self.footerReference = cell
            return cell
        default:
            return getScheduleCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

}
