//
//  AssignedRUPTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPTableViewCell: BaseTableViewCell {

    // MARK: Variables
    var rup: Plan?
    var agreement: Agreement?
    var bg: UIColor = UIColor.white
    var cellSelected: Bool = false

    // MARK: Outlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var statusLight: UIView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var rangeName: UILabel!

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var versionsHeight: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if rup != nil { autofill(rup: rup!)}
        style()
        self.selectionStyle = .none
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: Any) {
        guard let plan = rup, let presenter = self.getPresenter() else {return}
        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            presenter.showForm(for: plan, mode: .Edit)
        } else {
            presenter.showForm(for: plan, mode: .View)
        }
    }

    // MARK: Setup
    func setup(rup: Plan, color: UIColor, expand: Bool? = false) {
        self.agreement = RUPManager.shared.getAgreement(with: rup.agreementId)
        self.rup = rup
        autofill(rup: rup)
        self.bg = color
        if let exp = expand {
            if exp {
                self.styleSelected()
            } else {
                // Locked means it has decreased Alpha so the
                // selected one stands out
                setLocked()
            }
        } else {
            style()
        }
        setUpTable()
    }

    func autofill(rup: Plan) {
        self.idLabel.text = "\(rup.agreementId)"
        self.infoLabel.text = RUPManager.shared.getPrimaryAgreementHolderFor(rup: rup)
        self.rangeName.text = rup.rangeName
        self.statusText.text = rup.getStatus().rawValue.convertFromCamelCase()
    }

    // MARK: Styles
    func style() {
        self.cellSelected = false
        self.infoButton.setImage(#imageLiteral(resourceName: "icons_form_dropdownarrow"), for: .normal)
        self.statusLight.alpha = 1
        self.container.layer.shadowOpacity = 0
        self.infoButton.isUserInteractionEnabled = false

        self.container.backgroundColor = bg
        self.backgroundColor = bg

        container.layer.shadowRadius = 0
        versionsHeight.constant = 0
        tableContainer.alpha = 0

        infoButton.alpha = 1
        statusText.alpha = 1
        statusLight.alpha = 1

        makeCircle(view: statusLight)

        styleStaticField(field: idLabel)
        styleStaticField(field: infoLabel)
        styleStaticField(field: statusText)
        styleStaticField(field: rangeName)

        guard let plan = self.rup else {return}
        self.statusLight.backgroundColor = StatusHelper.getColor(for: plan.getStatus())
    }

    func styleSelected() {
        if cellSelected {return}
        self.cellSelected = true
        style()
        self.infoButton.alpha = 0
        self.statusLight.alpha = 0
        self.statusText.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.container.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
            self.addShadow(to: self.container.layer, opacity: 0.5, height: 2)
            self.divider.alpha = 1
            self.styleDivider(divider: self.divider)
            self.tableContainer.layer.cornerRadius = 5
            self.updateTableHeight()
            self.tableContainer.alpha = 1
            self.layoutIfNeeded()
        }) { (done) in
            self.infoButton.alpha = 1
            self.infoButton.setImage(#imageLiteral(resourceName: "up"), for: .normal)

        }
    }

    func styleDefault() {
        UIView.animate(withDuration: 0.3, animations: {
            self.style()
            self.cellSelected = false
        })
    }

    func setLocked() {
        style()
        UIView.animate(withDuration: 0.2, animations: {
            self.container.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
            self.versionsHeight.constant = 0
            self.divider.alpha = 0
            self.idLabel.textColor = Colors.lockedCell
            self.infoLabel.textColor = Colors.lockedCell
            self.statusText.textColor = Colors.lockedCell
            self.rangeName.textColor = Colors.lockedCell
            self.infoButton.setTitleColor(Colors.lockedCell, for: .normal)
            self.statusLight.alpha = 0.5
            self.layoutIfNeeded()
            self.cellSelected = false
        })
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }

    func updateTableHeight() {
        if let a = self.agreement {
            self.versionsHeight.constant = CGFloat(AssignedRUPVersionTableViewCell.cellHeight * (a.plans.count + 1))
            self.tableView.reloadData()
        } else {
            self.versionsHeight.constant = 0
        }
    }
}

// MARK: TableView

extension AssignedRUPTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AssignedRUPVersionTableViewCell")
        registerCell(name: "AssignedRUPVersionsHeaderTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> AssignedRUPVersionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AssignedRUPVersionTableViewCell", for: indexPath) as! AssignedRUPVersionTableViewCell
    }

    func getHeaderCell(indexPath: IndexPath) -> AssignedRUPVersionsHeaderTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AssignedRUPVersionsHeaderTableViewCell", for: indexPath) as! AssignedRUPVersionsHeaderTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = getHeaderCell(indexPath: indexPath)
            return cell
        }
        let cell = getCell(indexPath: indexPath)
        var color = Colors.oddCell
        if indexPath.row % 2 == 0 {color = Colors.evenCell}
        if let agreement = self.agreement {
            cell.setup(plan: agreement.plans[indexPath.row - 1], color: color)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let a = self.agreement {
            return a.plans.count + 1
        }
        return 0
    }
}
