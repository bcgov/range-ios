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
import DatePicker

class MonitoringAreaCustomDetailsTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var mode: FormMode = .View
    var area: MonitoringArea?
    var parentReference: MonitoringAreaViewController?
    var section: IndicatorPlantSection?

    // MARK: Outlets
    @IBOutlet weak var banner: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeader: UILabel!
    @IBOutlet weak var singleFieldValue: UITextField!
    @IBOutlet weak var sectionName: UILabel!
    @IBOutlet weak var headerLeft: UILabel!
    @IBOutlet weak var headerRight: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var singleFieldSectionHeight: NSLayoutConstraint!

    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func singleFieldAction(_ sender: UIButton) {
        guard let a = area, let parent = parentReference else {return}
        let picker = DatePicker()

        picker.setupYearless() { (selected, month, day) in
            if selected, let day = day, let month = month {
                do {
                    let realm = try Realm()
                    try realm.write {
                        a.readinessDay = day
                        a.readinessMonth = month
                    }
                } catch _ {
                    fatalError()
                }
                self.autofill()
            }
        }
        picker.displayPopOver(on: sender, in: parent) {}
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
        self.tableHeight.constant = computeHeight()
        setUpTable()
        setupSection()
        style()
        autofill()
        self.tableView.reloadData()
    }

    func autofill() {
        guard let a = self.area else {return}
        if a.readinessDay != -1 && a.readinessMonth != -1 {
            self.singleFieldValue.text = "\(DatePickerHelper.shared.month(number: a.readinessMonth)) \(a.readinessDay)"
        }
    }

    func style() {
        styleSubHeader(label: sectionName)
        styleFieldHeader(label: headerLeft)
        styleFieldHeader(label: headerRight)
        styleFieldHeader(label: banner)
        switch self.mode {
        case .View:
            addButton.alpha = 0
            styleInputFieldReadOnly(field: singleFieldValue, header: singleFieldHeader, height: singleFieldHeight)
        case .Edit:
            styleHollowButton(button: addButton)
            styleInputField(field: singleFieldValue, header: singleFieldHeader, height: singleFieldHeight)
        }
    }

    func setupSection() {
        guard let current = self.section else {return}
        self.headerLeft.text = "Indicator Plant"
        switch current {
        case .RangeReadiness:
            self.singleFieldSectionHeight.constant = 70
            self.sectionName.text = "Range Readiness"
            self.headerRight.text = "Criteria (Leaf Stage)"
            self.banner.text = ""
        case .StubbleHeight:
            self.singleFieldSectionHeight.constant = 0
            self.sectionName.text = "Stubble Height"
            self.headerRight.text = "Height After Grazing (cm)"
            self.banner.text = ""
        case .ShrubUse:
            self.singleFieldSectionHeight.constant = 0
            self.sectionName.text = "Shrub Use"
            self.headerRight.text = "% of Current Annual Growth"
            self.banner.text = "The default allowable browse level is 25% of current annual growth"
        }
    }

    func computeHeight() -> CGFloat {
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
        guard let parent = self.parentReference else {return}
        refreshMonitoringAreaObject()
        self.tableHeight.constant = computeHeight()
        parent.reload(then: {
            self.tableView.remembersLastFocusedIndexPath = true
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        })
//        self.tableView.reloadData()
//        self.tableView.layoutIfNeeded()
//        self.tableHeight.constant = computeHeight()
//        self.layoutIfNeeded()
//        parent.reload()
    }

    func refreshMonitoringAreaObject() {
        guard let a = area else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(MonitoringArea.self).filter("localId = %@", a.localId).first!
            self.area = temp
        } catch _ {
            fatalError()
        }
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
            cell.setup(mode: self.mode, indicatorPlant: indicatorPlant, area: a, parentReference: parent, parentCellReference: self)
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
