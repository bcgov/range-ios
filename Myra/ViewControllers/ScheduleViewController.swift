//
//  ScheduleViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleViewController: BaseViewController {

    // MARK: Variables
    var completion: ((_ done: Bool) -> Void)?
    var footerReference: ScheduleFooterTableViewCell?
    var schedule: Schedule?
    var rup: RUP?
    var popupContainerTag = 200
    var popover: UIPopoverPresentationController?

    // MARK: Outlets
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var navbar: UIView!
    @IBOutlet weak var statusbar: UIView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var navbarTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: (rup?.agreementId)!, agreementHolder: "", rangeName: (rup?.rangeName)!)
        style()
    }

    @IBAction func backAction(_ sender: UIButton) {
        if let r = self.rup {
            RealmRequests.updateObject(r)
        }
        self.dismiss(animated: true, completion: {
            return self.completion!(true)
        })
    }

    func setup(rup: RUP, schedule: Schedule, completion: @escaping (_ done: Bool) -> Void) {
        self.rup = rup
        self.schedule = schedule
        self.completion = completion
        let scheduleObjects = schedule.scheduleObjects
        for object in scheduleObjects {
            RUPManager.shared.calculate(scheduleObject: object)
        }
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: rup.agreementId, agreementHolder: "", rangeName: rup.rangeName)
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
        self.subtitle.text = "\(ranNumber) | \(agreementHolder) | \(rangeName)"
    }

    // Mark: Livestock selection popup
    func showpopup(vc: SelectionPopUpViewController, on: UIButton) {
        let popOverWidth = 200
        var popOverHeight = 300
        if vc.canDisplayFullContentIn(height: popOverHeight) {
            popOverHeight =  vc.getEstimatedHeight()
        }
        showPopOver(on: on, vc: vc, height: popOverHeight, width: popOverWidth)

        /*
        showWhiteScreen()
        if let whiteView = self.view.viewWithTag(whiteScreenTag) {

            let container = getLiveStockPopupHolder()
            
            whiteView.addSubview(container)
            addChildViewController(vc)
            container.addSubview(vc.view)
            vc.view.frame = container.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.didMove(toParentViewController: self)

        }*/
    }

    func hidepopup(vc: SelectionPopUpViewController) {
        vc.dismiss(animated: true, completion: nil)
        return
            /*
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        if let container = self.view.viewWithTag(popupContainerTag) {
            container.removeFromSuperview()
        }
        removeWhiteScreen()
        */
    }

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

    override func whenLandscape() {
        rotatePopup()
    }

    override func whenPortrait() {
        rotatePopup()
    }

    func reloadCells() {
        self.tableView.reloadData()
        print(self.tableView.frame.height)
    }

    func calculateTotals() {
        self.footerReference?.autofill()
    }

    // MARK: Styles
    func style() {
        styleNavBar(title: navbarTitle, navBar: navbar, statusBar: statusbar, primaryButton: backbutton, secondaryButton: nil, textLabel: nil)
        styleHeader(label: scheduleTitle)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
    }
}

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
            cell.setup(schedule: schedule!, rup: rup!, parentReference: self)
            return cell
        case 1:
            let cell = getScheduleFooterCell(indexPath: indexPath)
            cell.setup(schedule: schedule!, agreementID: (rup?.agreementId)!)
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
