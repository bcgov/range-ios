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

    @IBAction func viewAction(_ sender: UIButton) {
        guard let plan = rup else {return}
        let parent = self.parentViewController as! HomeViewController
        if plan.getStatus() == .LocalDraft || plan.getStatus() == .StaffDraft {
            parent.editRUP(rup: plan)
        } else {
            parent.viewRUP(rup: plan)
        }
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

        if let amendmentType = RUPManager.shared.getAmendmentType(forId: plan.amendmentTypeId) {
            self.type.text = amendmentType.name
        } else {
            self.type.text = "-"
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
        case .WronglyMadeWithoutEffect:
            setStatusGray()
        case .StandsWronglyMade:
            setStatusGray()
        case .Stands:
            setStatusGray()
        case .NotApprovedFurtherWorkRequired:
            setStatusGray()
        case .NotApproved:
            setStatusGray()
        case .Approved:
            setStatusGray()
        case .SubmittedForReview:
            setStatusGray()
        case .SubmittedForFinalDecision:
            setStatusGray()
        case .RecommendReady:
            setStatusGray()
        case .RecommendNotReady:
            setStatusGray()
        case .ReadyForFinalDescision:
            setStatusGray()
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
