//
//  PlantCommunityMonitoringAreasTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityMonitoringAreasTableViewCell: BaseTableViewCell {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?
    var rup: Plan?

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

    // MARK: Outlet Actions
    @IBAction func addMonitoringArea(_ sender: UIButton) {
        addNewMonitoringArea()
    }

    func addNewMonitoringArea(copyFrom: MonitoringArea? = nil) {
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Monitoring Area Name") { (name) in
            if name != "", let refetchedPlantCommunity = self.refetchPlantCommunity() {
                if let objectToCopyFrom = copyFrom {
                    refetchedPlantCommunity.addMonitoringArea(cloneFrom: objectToCopyFrom, withName: name)
                } else {
                    refetchedPlantCommunity.addMonitoringArea(withName: name)
                }
                self.plantCommunity = refetchedPlantCommunity
                self.updateTableHeight()
            }
        }
    }
    
    func refetchPlantCommunity() -> PlantCommunity? {
        guard let plantCommunity = self.plantCommunity else {return nil}
        do {
            let realm = try Realm()
            if let aCommunity = realm.objects(PlantCommunity.self).filter("localId = %@", plantCommunity.localId).first {
                return aCommunity
            } else {
                return nil
            }
        } catch _ {
            return nil
        }
    }

    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, rup: Plan, parentReference: PlantCommunityViewController) {
        self.plantCommunity = plantCommunity
        self.mode = mode
        self.parentReference = parentReference
        self.rup = rup
        self.height.constant = computeHeight()
        setUpTable()
        style()
    }

    func refreshPlantCommunityObject() {
        guard let p = self.plantCommunity else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(PlantCommunity.self).filter("localId = %@", p.localId).first!
            self.plantCommunity = temp
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }

    func updateTableHeight() {
        refreshPlantCommunityObject()
        guard let parent = self.parentReference else {return}
        self.height.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }

    func computeHeight() -> CGFloat {
        guard let p = self.plantCommunity else {return 0.0}
//        return CGFloat(p.monitoringAreas.count) * CGFloat(PlantCommunityMonitoringAreaTableViewCell.cellHeight)
        return CGFloat(p.monitoringAreas.count) * CGFloat(MonitoringAreaBasicInfoTableViewCell.cellHeight)
    }

    // MARK: Styles
    func style() {
        styleHollowButton(button: addButton)
        switch mode {
        case .View:
            addButton.alpha = 0
        case .Edit:
            addButton.alpha = 1
        }
    }
}

extension PlantCommunityMonitoringAreasTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "MonitoringAreaBasicInfoTableViewCell")
//        registerCell(name: "PlantCommunityMonitoringAreaTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getMonitoringAreaCell(indexPath: IndexPath) -> PlantCommunityMonitoringAreaTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityMonitoringAreaTableViewCell", for: indexPath) as! PlantCommunityMonitoringAreaTableViewCell
    }

    func getMonitoringAreaBasicInfoTableViewCell(indexPath: IndexPath) -> MonitoringAreaBasicInfoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MonitoringAreaBasicInfoTableViewCell", for: indexPath) as! MonitoringAreaBasicInfoTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = getMonitoringAreaCell(indexPath: indexPath)
        let cell = getMonitoringAreaBasicInfoTableViewCell(indexPath: indexPath)
        if let pc = self.plantCommunity, let parent = parentReference {
            cell.setup(mode: self.mode, monitoringArea: pc.monitoringAreas[indexPath.row], parentReference: parent, parentCellReference: self)
        }
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
