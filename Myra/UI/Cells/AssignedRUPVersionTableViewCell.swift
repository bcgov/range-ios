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
    @IBOutlet weak var toolTipButton: UIButton!


    @IBAction func viewAction(_ sender: UIButton) {
        guard let plan = rup, let parent = self.parentViewController as? HomeViewController else {return}
        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            parent.editRUP(rup: plan)
        } else {
            parent.viewRUP(rup: plan)
        }
    }
    
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let plan = rup, let parent = self.parentViewController as? HomeViewController else {return}
        let statusEnum = plan.getStatus()
        let currStatus = "\(statusEnum)"
        parent.showTooltip(on: sender, title: currStatus.convertFromCamelCase(), desc: Reference.shared.getStatusTooltipDeescription(for: statusEnum))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
        self.selectionStyle = .none
    }

    func setup(plan: RUP, color: UIColor) {
        self.rup = plan
        style()
        autofill()
        self.backgroundColor = color
    }

    func autofill() {
        guard let plan = self.rup else {return}

        self.status.text = plan.getStatus().rawValue

        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            viewButton.setTitle("Edit", for: .normal)
        } else {
            viewButton.setTitle("View", for: .normal)
        }
        
        if let effective = plan.effectiveDate {
            self.effectiveDate.text = effective.stringShort()
        } else {
            self.effectiveDate.text = "-"
        }

        if let submitted = plan.submitted {
            self.submitted.text = submitted.stringShort()
        } else {
            self.submitted.text = "-"
        }

        if let amendmentType = Reference.shared.getAmendmentType(forId: plan.amendmentTypeId) {
            self.type.text = amendmentType.name
        } else {
            self.type.text = "Initial Plan"
        }

    }

    // MARK: Styles
    func style() {
        makeCircle(view: statusLight)
        styleHollowButton(button: viewButton)
        styleStaticField(field: effectiveDate)
        styleStaticField(field: submitted)
        styleStaticField(field: type)

        guard let plan = self.rup else {return}
        self.statusLight.backgroundColor = StatusHelper.getColor(for: plan.getStatus())
    }
}
