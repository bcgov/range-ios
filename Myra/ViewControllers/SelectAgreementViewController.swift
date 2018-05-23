//
//  SelectAgreementViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectAgreementViewController: UIViewController, Theme {

    // MARK: Variables
    var parentCallBack: ((_ close: Bool) -> Void )?

    var agreements: [Agreement] = [Agreement]()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createNewRupHeader: UILabel!
    @IBOutlet weak var createNewRupFooter: UILabel!
    @IBOutlet weak var rangeNumberHeader: UILabel!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var divider: UIView!

    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.agreements = RUPManager.shared.getAgreementsWithNoRUPs()
        setUpTable()
        style()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: Outlet actions
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.parentCallBack != nil {
                return self.parentCallBack!(true)
            }
        })
    }

    // MARK: Setup
    func setup(callBack: @escaping ((_ close: Bool) -> Void )) {
        self.parentCallBack = callBack
    }

    // MARK: Style
    func style() {
        styleNavBar(title: pageTitle, navBar: navBar, statusBar: statusBar, primaryButton: cancelButton, secondaryButton: nil, textLabel: nil)
        styleHeader(label: createNewRupHeader)
        styleFooter(label: createNewRupFooter)
        styleFieldHeader(label: rangeNumberHeader)
        styleFieldHeader(label: agreementHolderHeader)
        styleDivider(divider: divider)
    }

    // MARK: Selection
    func createPlanFor(agreement: Agreement) {
        let rup = RUPManager.shared.genRUP(forAgreement: agreement)
        let vm = ViewManager()
        let createVC = vm.createRUP
        createVC.setup(rup: rup, mode: .Edit, callBack: {closed, cancel  in
            if cancel {
//                for plan in agreement.rups {
//                    plan.deleteEntries()
//                    RealmRequests.deleteObject(plan)
//                }
            }
            self.dismiss(animated: true, completion: {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true)
                }
            })
        })
        self.present(createVC, animated: true, completion: nil)
    }
}


// MARK: Tableview
extension SelectAgreementViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AgreementTableViewCell")
    }
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> AgreementTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AgreementTableViewCell", for: indexPath) as! AgreementTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agreements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        if indexPath.row % 2 == 0 {
            cell.setup(agreement: agreements[indexPath.row], bg: Colors.evenCell)
        } else {
            cell.setup(agreement: agreements[indexPath.row], bg: Colors.oddCell)
        }
        return cell
    }
}

