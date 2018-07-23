//
//  MonitoringAreaCustomDetailsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MonitoringAreaCustomDetailsTableViewCell: UITableViewCell {

    // MARK: Variables
    var mode: FormMode = .View
    var area: MonitoringArea?
    var parentReference: MonitoringAreaViewController?
    var section: IndicatorPlantSection?

    // MARK: Outlet actions
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeader: UILabel!
    @IBOutlet weak var singleFieldValue: UITextField!
    @IBOutlet weak var sectionName: UILabel!
    @IBOutlet weak var headerLeft: UILabel!
    @IBOutlet weak var headerRight: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func singleFieldAction(_ sender: UIButton) {

    }

    @IBAction func addAction(_ sender: UIButton) {
        guard let current = section, let a = area else {return}
        a.addIndicatorPlant(type: current)
        updateHeight()
    }

    // MARK: Setup
    func setup(section: IndicatorPlantSection, mode: FormMode, area: MonitoringArea, parentReference: MonitoringAreaViewController) {
        self.mode = mode
        self.area = area
        self.parentReference = parentReference
        self.section = section
        self.tableHeight.constant = getTableHeight()
        setUpTable()
        setupSection()
    }

    func setupSection() {
        guard let current = self.section else {return}
        self.headerLeft.text = "Indicator Plant"
        switch current {
        case .RangeReadiness:
            self.singleFieldHeight.constant = 70
            self.sectionName.text = "Range Readiness"
            self.headerRight.text = "Criteria (Leaf Stage)"
        case .StubbleHeight:
            self.singleFieldHeight.constant = 0
            self.sectionName.text = "Stubble Height"
            self.headerRight.text = "Height After Grazing (cm)"
        case .ShrubUse:
            self.singleFieldHeight.constant = 0
            self.sectionName.text = "Shrub Use"
            self.headerRight.text = "Height After Grazing (cm)"
        }
    }

    func getTableHeight() -> CGFloat {
        guard let current = section, let a = area else {return 0.0}
        var count = 0
        switch current {
        case .RangeReadiness:
            count = a.rangeReadiness.count
        case .StubbleHeight:
            count = a.stubbleHeight.count
        case .ShrubUse:
            count = a.shrubUse.count
        }
        return CGFloat(count) * CGFloat(MonitoringAreaCustomDetailTableViewCellTableViewCell.cellHeight)
    }

    func updateHeight() {
        guard let a = area, let parent = self.parentReference else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(MonitoringArea.self).filter("localId = %@", a.localId).first!
            self.area = temp
        } catch _ {
            fatalError()
        }

        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableHeight.constant = getTableHeight()
        self.layoutIfNeeded()
        parent.reload()
    }
    
}

extension MonitoringAreaCustomDetailsTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "MonitoringAreaCustomDetailTableViewCellTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getActionCell(indexPath: IndexPath) -> MonitoringAreaCustomDetailTableViewCellTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MonitoringAreaCustomDetailTableViewCellTableViewCell", for: indexPath) as! MonitoringAreaCustomDetailTableViewCellTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ip: IndicatorPlant?

        let cell = getActionCell(indexPath: indexPath)
        if let a = self.area, let parent = self.parentReference, let sec = self.section {
            switch sec {
            case .RangeReadiness:
                ip = a.rangeReadiness[indexPath.row]
            case .StubbleHeight:
                ip = a.stubbleHeight[indexPath.row]
            case .ShrubUse:
                ip = a.shrubUse[indexPath.row]
            }
            guard let indicatorPlant = ip else {return cell}
            cell.setup(mode: self.mode, indicatorPlant: indicatorPlant, area: a, parentReference: parent)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let a = self.area, let sec = self.section {
            switch sec {
            case .RangeReadiness:
                return a.rangeReadiness.count
            case .StubbleHeight:
                return a.stubbleHeight.count
            case .ShrubUse:
                return a.shrubUse.count
            }

        } else {
            return 0
        }
    }
}
