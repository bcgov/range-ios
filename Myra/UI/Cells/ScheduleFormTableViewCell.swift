//
//  ScheduleFormTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-07.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

enum ScheduleSort {
    case None
    case Pasture
    case LiveStock
    case DateIn
    case DateOut
    case Number
}

class ScheduleFormTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 45.0

    // Mark: Variables
    var mode: FormMode = .View
    var schedule: Schedule?
    var objects: [ScheduleObject] = [ScheduleObject]()
    var rup: RUP?
    var parentReference: ScheduleViewController?
    var currentSort: ScheduleSort = .None {
        didSet {
            sort()
        }
    }

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var height: NSLayoutConstraint!

    @IBOutlet weak var pasture: UIButton!
    @IBOutlet weak var livestock: UIButton!
    @IBOutlet weak var numAnimals: UIButton!
    @IBOutlet weak var dateIn: UIButton!
    @IBOutlet weak var dateOut: UIButton!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var graceDays: UILabel!
    @IBOutlet weak var PLD: UILabel!
    @IBOutlet weak var crownAUMs: UILabel!
    @IBOutlet weak var addButton: UIButton!

    // Mark: Outlet Actions
    @IBAction func addAction(_ sender: Any) {
        createEntry(from: nil)
    }
    @IBAction func sortPasture(_ sender: UIButton) {
        self.currentSort = .Pasture
    }
    @IBAction func sortLiveStock(_ sender: UIButton) {
        self.currentSort = .LiveStock
    }
    @IBAction func sortDateIn(_ sender: UIButton) {
        self.currentSort = .DateIn
    }
    @IBAction func sortDateOut(_ sender: UIButton) {
        self.currentSort = .DateOut
    }
    @IBAction func sortNumber(_ sender: UIButton) {
        self.currentSort = .Number
    }

    // Mark: Functions
    func createEntry(from: ScheduleObject?) {
        guard let sched = self.schedule else {return}
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            if let copyFrom = from {
                RUPManager.shared.copyScheduleObject(fromObject: copyFrom, inSchedule: aSchedule)
            } else {
                try realm.write {
                    let new = ScheduleObject()
                    new.isNew = true
                    aSchedule.scheduleObjects.append(new)
                    realm.add(new)
                }
            }
            self.schedule = aSchedule
        } catch _ {
            fatalError()
        }
        self.setObjects()
        // todo: Remove?
        parentReference?.calculateTotals()
        parentReference?.validate()
        sort()
    }

    func setObjects() {
        guard let sched = self.schedule else {return}
        self.objects.removeAll()
        for item in sched.scheduleObjects {
            objects.append(item)
        }
    }

    func deleteEntry(object: ScheduleObject) {
        guard let sched = self.schedule else {return}
        RealmRequests.deleteObject(object)
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            self.schedule = aSchedule
        } catch _ {
            fatalError()
        }
        self.setObjects()
        sort()
    }

    // MARK: Setup
    func setup(mode: FormMode,schedule: Schedule, rup: RUP, parentReference: ScheduleViewController) {
        self.parentReference = parentReference
        self.rup = rup
        self.mode = mode
        self.schedule = schedule
        self.setObjects()
        height.constant = CGFloat( Double((schedule.scheduleObjects.count)) * ScheduleFormTableViewCell.cellHeight + 5.0)
        setUpTable()
        style()
        switch mode {
        case .View:
            addButton.isEnabled = false
            addButton.alpha = 0
        case .Edit:
            addButton.isEnabled = true
            addButton.alpha = 1
        }
    }

    func updateTableHeight() {
        guard let sched = self.schedule else {return}
        do {
            let realm = try Realm()
            let temp = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            self.schedule = temp
        } catch _ {
            fatalError()
        }

        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        height.constant = CGFloat( Double((self.schedule?.scheduleObjects.count)!) * ScheduleFormTableViewCell.cellHeight + 5.0)
        if let parent = self.parentReference {
            parent.reloadCells()
        }
    }

    // MARK: Styles
    func style() {
        switchOffSortHeaders()
        switch currentSort {
        case .Pasture:
            switchOnSortHeader(button: pasture)
        case .LiveStock:
            switchOnSortHeader(button: livestock)
        case .DateIn:
            switchOnSortHeader(button: dateIn)
        case .DateOut:
            switchOnSortHeader(button: dateOut)
        case .Number:
            switchOnSortHeader(button: numAnimals)
        case .None:
            break
        }
        styleFieldHeader(label: days)
        styleFieldHeader(label: graceDays)
        styleFieldHeader(label: PLD)
        styleFieldHeader(label: crownAUMs)
        styleHollowButton(button: addButton)
    }

    func switchOffSortHeaders() {
        styleFieldHeaderOff(button: pasture)
        styleFieldHeaderOff(button: livestock)
        styleFieldHeaderOff(button: dateIn)
        styleFieldHeaderOff(button: dateOut)
        styleFieldHeaderOff(button: numAnimals)
        self.layoutIfNeeded()
    }

    func switchOnSortHeader(button: UIButton) {
        styleFieldHeaderOn(button: button)
        self.layoutIfNeeded()
    }

    // MARK: Sort

    // Note: Sort() calls updateTableHeight()
    func sort() {
        self.isUserInteractionEnabled = false
        switchOffSortHeaders()
        guard let sched = self.schedule else {return}
        switch currentSort {
        case .Pasture:
            switchOnSortHeader(button: pasture)
            self.objects = sched.scheduleObjects.sorted(by: {$0.pasture?.name ?? "" <  $1.pasture?.name ?? ""})
        case .LiveStock:
            switchOnSortHeader(button: livestock)
            self.objects = sched.scheduleObjects.sorted(by: {$0.liveStockTypeId  <  $1.liveStockTypeId })
        case .DateIn:
            switchOnSortHeader(button: dateIn)
            self.objects = sched.scheduleObjects.sorted(by: {$0.dateIn ?? Date() <  $1.dateIn ?? Date()})
        case .DateOut:
            switchOnSortHeader(button: dateOut)
            self.objects = sched.scheduleObjects.sorted(by: {$0.dateOut ?? Date() <  $1.dateOut ?? Date()})
        case .Number:
            switchOnSortHeader(button: numAnimals)
            self.objects = sched.scheduleObjects.sorted(by: {$0.numberOfAnimals <  $1.numberOfAnimals})
        case .None:
            break
        }
        updateTableHeight()
        self.isUserInteractionEnabled = true
    }
}

// MARK: Tableview
extension ScheduleFormTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleObjectTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleObjectCell(indexPath: IndexPath) -> ScheduleObjectTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleObjectTableViewCell", for: indexPath) as! ScheduleObjectTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getScheduleObjectCell(indexPath: indexPath)
        if let sched = self.schedule, let r = self.rup, let schedRef = parentReference, sched.scheduleObjects.count > indexPath.row {
            cell.setup(mode: mode, scheduleObject: objects[indexPath.row], rup: r, scheduleViewReference: schedRef, parentCell: self)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
}
