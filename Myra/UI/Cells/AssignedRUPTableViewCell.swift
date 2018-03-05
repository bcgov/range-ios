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
        let parent = self.parentViewController as! HomeViewController
        parent.viewRUP(rup: rup!)
    }


    // removed
    @IBAction func ammendAction(_ sender: Any) {
        if rup == nil {return}
        let parent = self.parentViewController as! HomeViewController
        parent.ammendRUP(rup: rup!)
    }

    // MARK: Functions
    func set(rup: RUP) {
        self.rup = rup
        setupView(rup: rup)
    }

    func setupView(rup: RUP) {
        self.idLabel.text = rup.id
        self.infoLabel.text = /*rup.info + ", Holder: " + */rup.primaryAgreementHolderLastName
        self.rangeName.text = rup.rangeName
        switch rup.statusEnum {
        case .Completed:
            self.statusText.text = "Completed"
            setStatusGreen()
        case .Pending:
            self.statusText.text = "Pending"
            setStatusYellow()
        case .Draft:
            self.statusText.text = "Draft"
            setStatusRed()
//        default:
//            self.statusText.text = "UNKNOWN"
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
}
