//
//  AssignedRUPVersionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Extended

class PlanVersionTableViewCell: BaseTableViewCell {

    // MARK: Variables
    static let cellHeight = 40
    var rup: Plan?

    // MARK: Outlets
    @IBOutlet weak var effectiveDate: UILabel!
    @IBOutlet weak var submitted: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusLight: UIView!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var toolTipButton: UIButton!

    // MARK: Cell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
        self.selectionStyle = .none
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: UIButton) {
        guard let plan = rup, let presenter = getPresenter() else {return}
        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            presenter.showForm(for: plan, mode: .Edit)
        } else {
            presenter.showForm(for: plan, mode: .View)
        }
    }
    
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let plan = rup, let parent = self.parentViewController as? HomeViewController else {return}
        let statusEnum = plan.getStatus()
        let currStatus = "\(statusEnum)"
        parent.showTooltip(on: sender, title: currStatus.convertFromCamelCase(), desc: Reference.shared.getStatusTooltipDeescription(for: statusEnum))
    }

    // MARK: Setup
    func setup(plan: Plan, color: UIColor) {
        self.rup = plan
        style()
        autofill()
        self.backgroundColor = color
    }

    func autofill() {
        guard let plan = self.rup else {return}

//        self.status.text = plan.getStatus().rawValue
        self.status.text = StatusHelper.getDescription(for: plan.getStatus()).displayName

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
