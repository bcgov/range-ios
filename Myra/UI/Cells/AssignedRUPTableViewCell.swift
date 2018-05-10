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
        if rup?.statusEnum == .Pending || rup?.statusEnum == .Outbox || rup?.statusEnum == .Completed {
            parent.viewRUP(rup: plan)
        } else if rup?.statusEnum == .Draft {
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
        infoButton.alpha = 0
        self.idLabel.text = "\(rup.agreementId)"
        self.infoLabel.text = RUPManager.shared.getPrimaryAgreementHolderFor(rup: rup)
        self.rangeName.text = rup.rangeName
        self.statusText.text = rup.status
        infoButton.alpha = 1
        if rup.statusEnum == .Draft {
            infoButton.setTitle("Edit", for: .normal)
        } else {
            infoButton.setTitle("View", for: .normal)
        }
        /*
        switch rup.statusEnum {
        case .Completed:
//            self.statusText.text = "Completed"
            infoButton.alpha = 0
            setStatusGreen()
        case .Pending:
//            self.statusText.text = "Pending"
            infoButton.alpha = 0
            setStatusRed()
        case .Draft:
//            self.statusText.text = "Draft"
            infoButton.setTitle("Edit", for: .normal)
            infoButton.alpha = 1
            setStatusRed()
        case .Outbox:
//            self.statusText.text = "Outbox"
            infoButton.alpha = 0
            setStatusGray()
        }
        */
    }

    // MARK: Styles
    func style() {
        makeCircle(view: statusLight)
        styleButton(button: infoButton)
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
