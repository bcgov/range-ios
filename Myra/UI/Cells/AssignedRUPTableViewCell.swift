//
//  AssignedRUPTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPTableViewCell: UITableViewCell {

    // MARK: Variables
    var rup: RUP?

    // MARK: Outlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var statusLight: UIView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var rangeName: UILabel!

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
    func setup(rup: RUP, color: UIColor) {
        self.rup = rup
        setupView(rup: rup)
        style()
        self.backgroundColor = color
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
        makeCircle(view: statusLight)
        styleButton(button: infoButton)
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

    func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.primary.cgColor
        button.setTitleColor(Colors.primary, for: .normal)
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
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
}
