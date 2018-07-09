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
        textEntry.setup { (accepted, value) in
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
                parent.removeWhiteScreen()
                textEntry.view.removeFromSuperview()
                textEntry.removeFromParentViewController()
                self.updateTableHeight()
            } else {
                parent.removeWhiteScreen()
                textEntry.view.removeFromSuperview()
                textEntry.removeFromParentViewController()
            }
        }
        parent.showTextEntry(vc: textEntry)
    }

    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, parentReference: PlantCommunityViewController) {
        self.plantCommunity = plantCommunity
        self.mode = mode
        self.parentReference = parentReference
        self.height.constant = CGFloat( plantCommunity.monitoringAreas.count) * CGFloat(PlantCommunityMonitoringAreaTableViewCell.cellHeight)
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

    func computeHeight() -> CGFloat {
        // size of lable + button + vertical paddings
        let staticHeight = 128
        // size of a monitoring area cell
        let monitoringAreaHeight = 50
        guard let p = self.plantCommunity else {return CGFloat(staticHeight)}
        return (CGFloat(staticHeight + (monitoringAreaHeight * p.monitoringAreas.count)))
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
        registerCell(name: "PlantCommunityMonitoringAreaTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getMonitoringAreaCell(indexPath: IndexPath) -> PlantCommunityMonitoringAreaTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityMonitoringAreaTableViewCell", for: indexPath) as! PlantCommunityMonitoringAreaTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getMonitoringAreaCell(indexPath: indexPath)
        if let pc = self.plantCommunity {
            cell.setup(monitoringArea: pc.monitoringAreas[indexPath.row], mode: self.mode)
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
