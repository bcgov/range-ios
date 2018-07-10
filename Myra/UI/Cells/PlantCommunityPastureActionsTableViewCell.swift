//
//  PlantCommunityPastureActionsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityPastureActionsTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var height: NSLayoutConstraint!

    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, parentReference: PlantCommunityViewController) {
        self.plantCommunity = plantCommunity
        self.mode = mode
        self.parentReference = parentReference
        self.height.constant = CGFloat( plantCommunity.monitoringAreas.count) * CGFloat(PlantCommunityActionTableViewCell.cellHeight)
        setUpTable()
        style()
    }

    func updateTableHeight() {
        guard let p = self.plantCommunity, let parent = self.parentReference else {return}

        do {
            let realm = try Realm()
            let temp = realm.objects(PlantCommunity.self).filter("localId = %@", p.localId).first!
            self.plantCommunity = temp
        } catch _ {
            fatalError()
        }

        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.height.constant = CGFloat(p.monitoringAreas.count) * CGFloat(PlantCommunityMonitoringAreaTableViewCell.cellHeight)

        parent.reload()
    }

    // MARK: Styles
    func style() {
        styleHollowButton(button: addButton)
    }

}

extension PlantCommunityPastureActionsTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PlantCommunityActionTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getActionCell(indexPath: IndexPath) -> PlantCommunityActionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityActionTableViewCell", for: indexPath) as! PlantCommunityActionTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getActionCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = self.plantCommunity {
            return p.monitoringAreas.count
        } else {
            return 0
        }
    }
}
