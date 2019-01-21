//
//  SelectAgreementViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectAgreementViewController: BaseViewController {

    // MARK: Variables
    var parentCallBack: ((_ close: Bool) -> Void )?

    var agreements: [Agreement] = [Agreement]()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createNewRupHeader: UILabel!
    @IBOutlet weak var createNewRupFooter: UILabel!
    @IBOutlet weak var rangeNumberHeader: UILabel!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchHolder: UIView!
    @IBOutlet weak var rangeNumberSort: UIButton!
    @IBOutlet weak var agreementHolderSort: UIButton!

    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.agreements = RUPManager.shared.getAgreementsWithNoRUPs()
        setUpTable()
        style()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: Outlet actions
    @IBAction func clearSearch(_ sender: UIButton) {
        clearButton.alpha = 0
        self.searchField.text = ""
        self.agreements = RUPManager.shared.getAgreementsWithNoRUPs()
        self.tableView.reloadData()
    }

    @IBAction func searchQueryChanged(_ sender: UITextField) {
        if let query = searchField.text {
            resetSort()
            if query == "" {
                clearButton.alpha = 0
                self.agreements = RUPManager.shared.getAgreementsWithNoRUPs()
            } else {
                clearButton.alpha = 1
                search(query: query)
            }
        }
    }

    @IBAction func rangeNumberSortAction(_ sender: UIButton) {
        sortByRangeNumber()
    }

    @IBAction func agreementHolderSortAction(_ sender: UIButton) {
        sortByAgreementHolder()
    }

    // MARK: Sort and search
    func sortByRangeNumber() {
        styleSortHeaderOff(button: agreementHolderSort)
        styleSortHeaderOn(button: rangeNumberSort)
        self.agreements = agreements.sorted(by: { Int($0.agreementId.replacingOccurrences(of: "RAN", with: ""))! < Int($1.agreementId.replacingOccurrences(of: "RAN", with: ""))! })
        self.tableView.reloadData()
    }

    func sortByAgreementHolder() {
        styleSortHeaderOff(button: rangeNumberSort)
        styleSortHeaderOn(button: agreementHolderSort)
        self.agreements = agreements.sorted(by: { $0.primaryAgreementHolder() < $1.primaryAgreementHolder() })
        self.tableView.reloadData()
    }

    func resetSort() {
        styleSortHeaderOff(button: rangeNumberSort)
        styleSortHeaderOff(button: agreementHolderSort)
    }

    func search(query: String) {
        let all = RUPManager.shared.getAgreementsWithNoRUPs()
        var result: [Agreement] = [Agreement]()
        for agreement in all {
            if agreement.agreementId.lowercased().contains(query.lowercased()) || agreement.primaryAgreementHolder().lowercased().contains(query.lowercased()){
                result.append(agreement)
            }
        }
        
        self.agreements = result
        self.tableView.reloadData()
    }


    // MARK: Setup
    func setup(callBack: @escaping ((_ close: Bool) -> Void )) {
        self.parentCallBack = callBack
    }

    // MARK: Style
    func style() {
        styleHeader(label: createNewRupHeader)
        styleFooter(label: createNewRupFooter)
        styleDivider(divider: divider)
        
        // custom styling of search. move to theme if search is used elsewhere
        searchField.textColor = defaultInputFieldTextColor()
        searchField.font = defaultInputFieldFont()
        searchField.backgroundColor = defaultInputFieldBackground()
        searchHolder.backgroundColor = defaultInputFieldBackground()
        searchHolder.layer.cornerRadius = 3
        resetSort()
    }

    // MARK: Selection
    func createPlanFor(agreement: Agreement) {
        guard let presenter = self.getPresenter() else {return}
        let plan = RUPManager.shared.genRUP(forAgreement: agreement)
        presenter.showForm(for: plan, mode: .Edit)
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

