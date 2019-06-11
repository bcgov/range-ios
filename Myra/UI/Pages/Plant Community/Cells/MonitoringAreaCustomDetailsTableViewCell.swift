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

class MonitoringAreaCustomDetailsTableViewCell: BaseTableViewCell {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?
    var section: IndicatorPlantSection?

    // MARK: Outlets
    @IBOutlet weak var container: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var singleFieldHeader: UILabel!
    @IBOutlet weak var singleFieldValue: UITextField!
    @IBOutlet weak var headerLeft: UILabel!
    @IBOutlet weak var headerRight: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var singleFieldSectionHeight: NSLayoutConstraint!

    @IBOutlet weak var readinessNotesHeader: UILabel!
    @IBOutlet weak var sectionTitle: UILabel!

    @IBOutlet weak var sectionSubtitle: UILabel!

    @IBOutlet weak var readinessNotesTextView: UITextView!
    @IBOutlet weak var readinessNotesSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var sectionTitleContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var tableHeadersHeight: NSLayoutConstraint!

    @IBOutlet weak var readinessSection: UIView!
    @IBOutlet weak var notesSection: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions

    @IBAction func otherToolTipAction(_ sender: UIButton) {
        guard let parent = parentReference else {return}
        parent.showTooltip(on: sender, title: "Other", desc: InfoTips.rangeReadinessOther)
    }

    @IBAction func singleFieldAction(_ sender: UIButton) {
        guard let a = plantCommunity, let parent = parentReference else {return}
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
                    Logger.fatalError(message: LogMessages.databaseWriteFailure)
                }
                self.autofill()
            }
        }
        picker.displayPopOver(on: sender, in: parent) {}
    }

    @IBAction func addAction(_ sender: UIButton) {
        guard let current = section, let a = plantCommunity else {return}
        a.addIndicatorPlant(type: current)
        updateHeight()
    }

    // MARK: Setup
    func setup(section: IndicatorPlantSection, mode: FormMode, plantCommunity: PlantCommunity, parentReference: PlantCommunityViewController) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.parentReference = parentReference
        self.section = section
        self.tableHeight.constant = computeHeight()
        setUpTable()
        setupSection()
        style()
        autofill()
        readinessNotesTextView.delegate = self
        self.tableView.reloadData()
    }

    func autofill() {
        guard let a = self.plantCommunity else {return}
        if a.readinessDay != -1 && a.readinessMonth != -1 {
            self.singleFieldValue.text = "\(DatePickerHelper.shared.month(number: a.readinessMonth)) \(a.readinessDay)"
        }
        self.readinessNotesTextView.text = a.readinessNotes
        styleTableHeaders()
    }

    func styleTableHeaders() {
        if numberOfElements() < 1 {
            headerLeft.alpha = 0
            headerRight.alpha = 0
            tableHeadersHeight.constant = 0
        } else {
            headerLeft.alpha = 1
            headerRight.alpha = 1
            tableHeadersHeight.constant = 50
        }
    }

    func style() {
        styleFieldHeader(label: headerLeft)
        styleFieldHeader(label: headerRight)
        styleSubHeader(label: sectionTitle)
        sectionSubtitle.font = Fonts.getPrimary(size: 17)
        styleContainer(view: container)
        switch self.mode {
        case .View:
            addButton.alpha = 0
            styleInputFieldReadOnly(field: singleFieldValue, header: singleFieldHeader, height: singleFieldHeight)
            styleTextviewInputFieldReadOnly(field: readinessNotesTextView, header: readinessNotesHeader)
        case .Edit:
            styleHollowButton(button: addButton)
            styleInputField(field: singleFieldValue, header: singleFieldHeader, height: singleFieldHeight)
            styleTextviewInputField(field: readinessNotesTextView, header: readinessNotesHeader)
        }
    }

    func setupSection() {
        guard let current = self.section else {return}
        self.headerLeft.text = "Plant Growth:"
        self.headerRight.text = ""
        switch current {
        case .RangeReadiness:
            self.sectionSubtitle.text = "If more than one readiness criteria is provided, all such criteria must be met before grazing may accur."
            self.sectionTitleContainerHeight.constant = 80
            self.readinessNotesSectionHeight.constant = 100
            self.singleFieldSectionHeight.constant = 70
            self.singleFieldHeader.alpha = 1
            self.sectionTitle.text = "Range Readiness:"
            self.readinessNotesTextView.alpha = 1
            self.notesSection.alpha = 1
        case .StubbleHeight:
            self.sectionSubtitle.text = "Livestock must be removed on the first to occur of the date in the plan (ex. schedule), stubble height criteria or average browse criteria."
            self.notesSection.alpha = 0
            self.sectionTitleContainerHeight.constant = 80
            self.readinessNotesSectionHeight.constant = 0
            self.singleFieldSectionHeight.constant = 0
            self.singleFieldHeader.alpha = 0
            self.sectionTitle.text = "Stubble Height:"
        }
    }

    func computeHeight() -> CGFloat {
        guard let current = section, let a = plantCommunity else {return 0.0}
        var count = 0
        switch current {
        case .RangeReadiness:
            count = a.rangeReadiness.count
        case .StubbleHeight:
            count = a.stubbleHeight.count
        }
        return CGFloat(count) * CGFloat(MonitoringAreaCustomDetailTableViewCellTableViewCell.cellHeight)
    }

    func updateHeight() {
        guard let parent = self.parentReference else {return}
        styleTableHeaders()
        refreshMonitoringAreaObject()
        self.tableHeight.constant = computeHeight()
        parent.reload(then: {
            self.tableView.remembersLastFocusedIndexPath = true
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        })
    }

    func refreshMonitoringAreaObject() {
        guard let a = plantCommunity else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(PlantCommunity.self).filter("localId = %@", a.localId).first!
            self.plantCommunity = temp
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }
}

extension MonitoringAreaCustomDetailsTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let a = plantCommunity, let text = textView.text else {return}
        do {
            let realm = try Realm()
            try realm.write {
                a.readinessNotes = text
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
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
        if let plantCommunity = self.plantCommunity, let parent = self.parentReference, let sec = self.section {
            switch sec {
            case .RangeReadiness:
                ip = plantCommunity.rangeReadiness[indexPath.row]
            case .StubbleHeight:
                ip = plantCommunity.stubbleHeight[indexPath.row]
            }
            guard let indicatorPlant = ip else {return cell}
            cell.setup(forSection: sec, mode: self.mode, indicatorPlant: indicatorPlant, plantCommunity: plantCommunity, parentReference: parent, parentCellReference: self)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfElements()
    }

    func numberOfElements() -> Int {
        if let a = self.plantCommunity, let sec = self.section {
            switch sec {
            case .RangeReadiness:
                return a.rangeReadiness.count
            case .StubbleHeight:
                return a.stubbleHeight.count
            }
        } else {
            return 0
        }
    }
}
