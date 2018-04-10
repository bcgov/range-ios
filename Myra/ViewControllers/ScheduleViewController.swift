//
//  ScheduleViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

    @IBOutlet weak var popupContainer: UIView!

    var completion: ((_ done: Bool) -> Void)?
    var footerReference: ScheduleFooterTableViewCell?
    var schedule: Schedule?
    var rup: RUP?

    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        popupContainer.alpha = 0 
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: (rup?.agreementId)!, agreementHolder: "", rangeName: (rup?.rangeName)!)
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

    func showpopup(vc: SelectionPopUpViewController) {
        add(asChildViewController: vc)
        self.popupContainer.alpha = 1
    }

    func hidepopup(vc: SelectionPopUpViewController) {
        remove(asChildViewController: vc)
        self.popupContainer.alpha = 0
    }

    func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        popupContainer.addSubview(viewController.view)
        viewController.view.frame = popupContainer.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }

    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    func reloadCells() {
        self.tableView.reloadData()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func calculateTotals() {
        self.footerReference?.setValues()
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
