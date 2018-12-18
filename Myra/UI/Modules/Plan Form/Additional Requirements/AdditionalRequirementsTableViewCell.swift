//
//  AdditionalRequirementsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class AdditionalRequirementsTableViewCell: BaseFormCell {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    @IBAction func addAction(_ sender: UIButton) {
        do {
            let realm = try Realm()
            try realm.write {
                rup.additionalRequirements.append(AdditionalRequirement())
                NewElementAddedBanner.shared.show()
            }
        } catch {
            fatalError()
        }
        updateTableHeight(scrollToBottom: true)
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Additional Requirements", desc: InfoTips.additionalRequirements)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.rup = rup
        style()
        autoFill()
        tableHeight.constant = computeHeight()
    }

    func autoFill() {

    }

    func style() {
        switch self.mode {
        case .View:
            self.addButton.alpha = 0
        case .Edit:
            styleHollowButton(button: addButton)
        }

        styleHeader(label: titleLabel, divider: divider)
        titleLabel.increaseFontSize(by: -4)
        styleSubHeader(label: subtitle)
    }

    func updateTableHeight(scrollToBottom: Bool) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        tableHeight.constant = computeHeight()

        if scrollToBottom {
            parent.realod(bottomOf: parent.additionalRequirementsIndexPath, then: {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            })
        } else {
            parent.reload {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
        }
    }

    func computeHeight() -> CGFloat {
        var h: CGFloat = 0.0
        for _ in rup.additionalRequirements {
            h = h + AdditionalRequirementTableViewCell.cellHeight
        }
        return h
    }

}


extension AdditionalRequirementsTableViewCell:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AdditionalRequirementTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getAdditionalRequirementCell(indexPath: IndexPath) -> AdditionalRequirementTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AdditionalRequirementTableViewCell", for: indexPath) as! AdditionalRequirementTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getAdditionalRequirementCell(indexPath: indexPath)
        cell.setup(mode: mode, object: self.rup.additionalRequirements[indexPath.row], parentCell: self)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rup.additionalRequirements.count
    }
}

