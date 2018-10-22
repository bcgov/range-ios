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

class PlantCommunityMonitoringAreasTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?
    var rup: RUP?

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
        guard let pc = self.plantCommunity, let parent = self.parentReference else {return}
        let vm = ViewManager()
        let textEntry = vm.textEntry
        textEntry.setup(on: parent, header: "Monitoring Area Name") { (accepted, value) in
            if accepted {
                let newMonitoringArea = MonitoringArea()
                newMonitoringArea.name = value
                do {
                    let realm = try Realm()
                    let aCommunity = realm.objects(PlantCommunity.self).filter("localId = %@", pc.localId).first!
                    try realm.write {
                        aCommunity.monitoringAreas.append(newMonitoringArea)
                        realm.add(newMonitoringArea)
                    }
                    self.plantCommunity = aCommunity

                } catch _ {
                    fatalError()
                }
                self.updateTableHeight()
//                parent.showMonitoringAreaDetailsPage(monitoringArea: newMonitoringArea)
            }
        }
    }

    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, rup: RUP, parentReference: PlantCommunityViewController) {
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
            fatalError()
        }
    }

    func updateTableHeight() {
        refreshPlantCommunityObject()
        guard let parent = self.parentReference else {return}
        self.height.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
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
            cell.setup(mode: self.mode, monitoringArea:  pc.monitoringAreas[indexPath.row], parentReference: parent)
//            cell.setup(monitoringArea: pc.monitoringAreas[indexPath.row], mode: self.mode, parentCellReference: self, parentReference: parent)
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
