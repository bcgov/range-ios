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

    // Removed
    @IBOutlet weak var ammendButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
        if rup != nil { setupView(rup: rup!)}
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: Any) {
        if rup == nil {return}
        if rup?.statusEnum == .Outbox {return}
        let parent = self.parentViewController as! HomeViewController
        parent.editRUP(rup: rup!)
    }


    // removed
    @IBAction func ammendAction(_ sender: Any) {
    }

    // MARK: Functions
    func set(rup: RUP) {
        self.rup = rup
        setupView(rup: rup)
    }

    func setupView(rup: RUP) {
        self.idLabel.text = "\(rup.agreementId)"
        self.infoLabel.text = RUPManager.shared.getPrimaryAgreementHolderFor(rup: rup)
        self.rangeName.text = rup.rangeName
        switch rup.statusEnum {
        case .Completed:
            self.statusText.text = "Completed"
            setStatusGreen()
        case .Pending:
            self.statusText.text = "Submitted"
            setStatusRed()
        case .Draft:
            self.statusText.text = "Draft"
            infoButton.setTitle("Edit", for: .normal)
            setStatusRed()
        case .Outbox:
            self.statusText.text = "Outbox"
            infoButton.alpha = 0
            setStatusGray()
        }
    }
}

// Mark: Styles
extension AssignedRUPTableViewCell {
    func style() {
        makeCircle(view: statusLight)
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
