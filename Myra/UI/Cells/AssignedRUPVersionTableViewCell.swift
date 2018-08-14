//
//  AssignedRUPVersionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPVersionTableViewCell: UITableViewCell, Theme {
    static let cellHeight = 40

    var rup: RUP?

    @IBOutlet weak var effectiveDate: UILabel!
    @IBOutlet weak var submitted: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusLight: UIView!
    @IBOutlet weak var viewButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Styles
    func style() {
        makeCircle(view: statusLight)

        styleHollowButton(button: viewButton)

        styleStaticField(field: effectiveDate)
        styleStaticField(field: submitted)
        styleStaticField(field: type)

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
    
}
