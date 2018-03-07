//
//  ScheduleViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

    var schedule: Schedule?

    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(schedule)
        setup()
        setUpTable()
    }

    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveAction(_ sender: UIButton) {
    }

    @IBAction func deleteAction(_ sender: UIButton) {
    }

    func setup() {
//        setTitle()
    }

    func setTitle() {
        self.scheduleTitle.text = schedule?.name
    }

    func setSubtitle(ranNumber: String, agreementHolder: String, rangeName: String) {
        self.subtitle.text = "\(ranNumber) | \(agreementHolder) | \(rangeName)"
    }
}

extension ScheduleViewController:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleFormTableViewCell")
        registerCell(name: "AgreementInformationTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleCell(indexPath: IndexPath) -> ScheduleFormTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleFormTableViewCell", for: indexPath) as! ScheduleFormTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = getScheduleCell(indexPath: indexPath)
            return cell
        default:
            return getScheduleCell(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
