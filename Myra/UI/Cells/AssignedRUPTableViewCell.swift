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
        style()
        if rup != nil { setupView(rup: rup!)}
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: Any) {
        guard let plan = rup else {return}
        let parent = self.parentViewController as! HomeViewController
        if plan.statusEnum == .Pending || plan.statusEnum == .Outbox || plan.statusEnum == .Completed {
            parent.viewRUP(rup: plan)
        } else if plan.statusEnum == .Draft {
            parent.editRUP(rup: plan)
        }
    }

    // MARK: Functions
    func set(rup: RUP, color: UIColor) {
        self.rup = rup
        setupView(rup: rup)
        self.backgroundColor = color
    }

    func setupView(rup: RUP) {
        self.idLabel.text = "\(rup.agreementId)"
        self.infoLabel.text = RUPManager.shared.getPrimaryAgreementHolderFor(rup: rup)
        self.rangeName.text = rup.rangeName
        self.statusText.text = rup.status
        if rup.statusEnum == .Draft {
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
        switch plan.statusEnum {
        case .Completed:
            setStatusGreen()
        case .Pending:
            setStatusYellow()
        case .Draft:
            setStatusRed()
        case .Outbox:
            setStatusGray()
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
