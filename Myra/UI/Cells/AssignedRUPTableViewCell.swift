//
//  AssignedRUPTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var rup: RUP?
    var bg: UIColor = UIColor.white

    // MARK: Outlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var statusLight: UIView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var rangeName: UILabel!

    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var versionsHeight: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if rup != nil { setupView(rup: rup!)}
        style()
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: Any) {
        guard let plan = rup else {return}
        let parent = self.parentViewController as! HomeViewController
        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            parent.editRUP(rup: plan)
        } else {
            parent.viewRUP(rup: plan)
        }
    }

    // MARK: Functions
    func setup(rup: RUP, color: UIColor, expand: Bool? = nil) {
        self.rup = rup
        setupView(rup: rup)
        self.bg = color
        if let exp = expand {
            if exp{
                styleSelected()
            } else {
                setLocked()
            }
        } else {
            style()
        }
        setUpTable()
    }

    func setupView(rup: RUP) {
        self.idLabel.text = "\(rup.agreementId)"
        self.infoLabel.text = RUPManager.shared.getPrimaryAgreementHolderFor(rup: rup)
        self.rangeName.text = rup.rangeName
        self.statusText.text = rup.getStatus().rawValue.convertFromCamelCase()
        if rup.getStatus() == .LocalDraft || rup.getStatus() == .StaffDraft {
            infoButton.setTitle("Edit", for: .normal)
        } else {
            infoButton.setTitle("View", for: .normal)
        }
    }

    // MARK: Styles
    func style() {
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

        styleHollowButton(button: infoButton)

        styleStaticField(field: idLabel)
        styleStaticField(field: infoLabel)
        styleStaticField(field: statusText)
        styleStaticField(field: rangeName)

        guard let plan = self.rup else {return}
        switch plan.getStatus() {
        case .Completed:
            setStatusGreen()
        case .Pending:
            setStatusYellow()
        case .LocalDraft:
            setStatusRed()
        case .Outbox:
            setStatusGray()
        case .Created:
            setStatusYellow()
        case .ChangeRequested:
            setStatusGray()
        case .ClientDraft:
            setStatusRed()
        case .Unknown:
            setStatusGray()
        case .StaffDraft:
            setStatusGreen()
        }
    }

    func setStatusRed() {
        self.statusLight.backgroundColor = UIColor.red
    }

    func setStatusGreen() {
        self.statusLight.backgroundColor = UIColor.green
    }

    func setStatusYellow() {
        self.statusLight.backgroundColor = UIColor.yellow
    }

    func setStatusGray() {
        self.statusLight.backgroundColor = UIColor.gray
    }

    func styleSelected() {
//        style()
        UIView.animate(withDuration: 0.3, animations: {
            self.container.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
            self.addShadow(layer: self.container.layer)
            self.tableContainer.layer.borderWidth = 1
            self.tableContainer.layer.borderColor = Colors.lockedCell.cgColor
            self.tableContainer.layer.cornerRadius = 5
            self.infoButton.alpha = 0
            self.statusText.alpha = 0
            self.statusLight.alpha = 0
            self.updateTableHeight()
            self.tableContainer.alpha = 1
            self.layoutIfNeeded()
        })
    }

    func setLocked() {
        style()
        UIView.animate(withDuration: 0.2, animations: {
            self.container.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
            self.versionsHeight.constant = 0
            self.idLabel.textColor = Colors.lockedCell
            self.infoLabel.textColor = Colors.lockedCell
            self.statusText.textColor = Colors.lockedCell
            self.rangeName.textColor = Colors.lockedCell
            self.infoButton.layer.borderColor = Colors.lockedCell.cgColor
            self.infoButton.setTitleColor(Colors.lockedCell, for: .normal)
            self.statusLight.alpha = 0.5
            self.layoutIfNeeded()
        })
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }

    func updateTableHeight() {
        // count of versions * AssignedRUPVersionTableViewCell.cellHeight
        self.versionsHeight.constant = CGFloat(AssignedRUPVersionTableViewCell.cellHeight * 2)
    }
}

// MARK: TableView

extension AssignedRUPTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AssignedRUPVersionTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> AssignedRUPVersionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AssignedRUPVersionTableViewCell", for: indexPath) as! AssignedRUPVersionTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
