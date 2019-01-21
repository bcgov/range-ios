//
//  ScheduleViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleViewController: BaseViewController {

    // MARK: Variables
    var footerReference: ScheduleFooterTableViewCell?
    var schedule: Schedule?
    var entries: [ScheduleObject] = [ScheduleObject]()
    var rup: Plan?
    var mode: FormMode = .View
    var popupContainerTag = 200
    var popover: UIPopoverPresentationController?

    var realmNotificationToken: NotificationToken?

    var currentSort: ScheduleSort = .None {
        didSet {
            sort()
        }
    }

    // MARK: Outlets
    // Top
    @IBOutlet weak var scrollToTopButton: UIButton!

    @IBOutlet weak var scrollToBottomButton: UIButton!
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var divider: UIView!

    // Headers
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

    // Banner
    @IBOutlet weak var bannerLabel: UILabel!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var banner: UIView!

    // Bottom
    @IBOutlet weak var authAUMsHeader: UILabel!
    @IBOutlet weak var authAUMs: UILabel!
    @IBOutlet weak var totalAUMsHeader: UILabel!
    @IBOutlet weak var totalAUMs: UILabel!
    @IBOutlet weak var bottomDivider: UIView!

    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setTitle()
        if let rup = self.rup {
            setSubtitle(ranNumber: (rup.agreementId), agreementHolder: "", rangeName: (rup.rangeName))
        }
        style()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateEntries()
        validate()
        
        if let r = self.rup {
            RealmRequests.updateObject(r)
        }
    }

    // MARK: Outlet Actions
    @IBAction func scrollToTop(_ sender: UIButton) {
        let indexPath = IndexPath(row:0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    @IBAction func scrollToButtom(_ sender: UIButton) {
        let indexPath = IndexPath(row: entries.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

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

    // MARK: Add / Remove entry
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
            self.entries = Array(aSchedule.scheduleObjects)
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }

        clearSort()
        let newEntryIndexPath = IndexPath(row: findIndexOfNew() ?? entries.count - 1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [newEntryIndexPath], with: .right)
        self.tableView.endUpdates()
        NewElementAddedBanner.shared.show()
        self.validate()
    }

    func findIndexOfNew() -> Int? {
        for i in 0...entries.count - 1 {
            if entries[i].isNew {
                return i
            }
        }
        return nil
    }

    func findIndexOf(entry: ScheduleObject) -> Int? {
        for i in 0...entries.count - 1 {
            if entries[i].localId == entry.localId {
                return i
            }
        }
        return nil
    }

    func deleteEntry(object: ScheduleObject) {
        if object.isInvalidated {
            clearSort()
            refreshScheduleObject()
            self.tableView.reloadData()
            self.validate()
            return
        }
        if let index = findIndexOf(entry: object) {
            RealmRequests.deleteObject(object)
            refreshScheduleObject()
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.tableView.endUpdates()
        } else {
            RealmRequests.deleteObject(object)
            refreshScheduleObject()
            self.tableView.reloadData()
        }

        self.validate()
        self.sort()
    }

    // MARK: Setup
    func setup(mode: FormMode, rup: Plan, schedule: Schedule) {
        self.rup = rup
        self.mode = mode
        self.schedule = schedule
        self.entries = Array(schedule.scheduleObjects)
        calculateEntries()
        setUpTable()
        setTitle()
        setSubtitle(ranNumber: rup.agreementId, agreementHolder: "", rangeName: rup.rangeName)

       beginChangeListener()
    }
    
    func beginChangeListener() {
        guard let schedule = self.schedule else {return}
        print("Listening to schedule changes")
        self.realmNotificationToken = schedule.observe { (change) in
            switch change {
            case .error(_):
                print("Error in rup change")
            case .change(_):
                self.validate()
            case .deleted:
                print("RUP deleted")
            }
        }
    }
    
    func endChangeListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            print("Stopped Listening to schedule changes :(")
        }
    }

    func setTitle() {
        guard let schedule = self.schedule, self.scheduleTitle != nil else {return}
        navigationTitle = "\(schedule.yearString) Grazing Schedule"
    }

    func setSubtitle(ranNumber: String, agreementHolder: String, rangeName: String) {
        if self.subtitle == nil { return }
        self.subtitle.text = "\(ranNumber) | \(rangeName)"
    }

    // MARK: Calculations
    func calculateEntries() {
        guard let sched = self.schedule else {return}
        for entry in sched.scheduleObjects {
            entry.calculateAUMsAndPLD()
        }
    }

    // MARK: Table Reload
    func reload(then: @escaping()-> Void) {
        refreshScheduleObject()
        if #available(iOS 11.0, *) {
            self.tableView.performBatchUpdates({
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }, completion: { done in
                self.tableView.layoutIfNeeded()
                return then()
            })
        } else {
            self.tableView.reloadSections([0], with: .automatic)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.layoutIfNeeded()
            return then()
        }
    }

    func refreshScheduleObject() {
        guard let sched = self.schedule else {return}
        do {
            let realm = try Realm()
            let aSchedule = realm.objects(Schedule.self).filter("localId = %@", sched.localId).first!
            self.schedule = aSchedule
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
        self.entries = Array(sched.scheduleObjects)
    }

    // MARK: Styles
    func style() {
        styleHeader(label: scheduleTitle)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
        styleDivider(divider: bottomDivider)
        authAUMsHeader.font = Fonts.getPrimaryBold(size: 17)
        totalAUMsHeader.font = Fonts.getPrimaryBold(size: 17)
        styleResult(label: authAUMs)
        styleResult(label: totalAUMs)
        styleSortHeaders()
        styleFillButton(button: scrollToTopButton)
        styleFillButton(button: scrollToBottomButton)
    }

    func styleResult(label: UILabel) {
        styleFieldHeader(label: label)
        let layer = label.layer
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
    }

    func styleSortHeaders() {
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
        switch mode {
        case .View:
            addButton.isEnabled = false
            addButton.alpha = 0
        case .Edit:
            addButton.isEnabled = true
            addButton.alpha = 1
        }
    }
    func switchOffSortHeaders() {
        self.view.layoutIfNeeded()
        styleSortHeaderOff(button: pasture)
        styleSortHeaderOff(button: livestock)
        styleSortHeaderOff(button: dateIn)
        styleSortHeaderOff(button: dateOut)
        styleSortHeaderOff(button: numAnimals)
        self.view.layoutIfNeeded()
    }

    func switchOnSortHeader(button: UIButton) {
        styleSortHeaderOn(button: button)
        self.view.layoutIfNeeded()
    }

    override func whenPortrait() {
        self.view.layoutIfNeeded()
    }

    override func whenLandscape() {
        self.view.layoutIfNeeded()
    }

    // MARK: Banner
    func openBanner(message: String) {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.bannerLabel.textColor = Colors.primary
            self.banner.backgroundColor = Colors.secondaryBg.withAlphaComponent(1)
            self.bannerHeight.constant = 50
            self.bannerLabel.text = message
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
                    self.bannerLabel.textColor = Colors.primaryConstrast
                    self.view.layoutIfNeeded()
                })
            })
        }
    }

    func highlightBanner() {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.bannerLabel.textColor = Colors.primary.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
                    self.bannerLabel.textColor = Colors.primary.withAlphaComponent(1)
                    self.view.layoutIfNeeded()
                })
            })
        }
    }

    func closeBanner() {
        self.bannerHeight.constant = 0
        animateIt()
    }

    // MARK: Validation
    func validate() {
        guard let current = schedule, let plan = rup else {return}
        autofillTotals()
        let valid = RUPManager.shared.validateSchedule(schedule: current, agreementID: plan.agreementId)
        if !valid.0 {
            openBanner(message: valid.1)
        } else {
            closeBanner()
        }
    }

    // MARK: Footer/results
    func autofillTotals() {
        guard let schedule = self.schedule, let plan = self.rup else {return}
        let totAUMs = schedule.getTotalAUMs()
        self.totalAUMs.text = "\(totAUMs.rounded())"

        if let usage = RUPManager.shared.getUsageFor(year: (schedule.year), agreementId: plan.agreementId) {
            let allowed = usage.auth_AUMs
            self.authAUMs.text = "\(allowed)"
            if totAUMs >= Double(allowed) {
                totalAUMs.textColor = UIColor.red
            } else {
                totalAUMs.textColor = UIColor.black
            }
        } else {
            self.totalAUMs.text = "NA"
        }
    }

    // MARK: Sort
    // Note: Sort() calls updateTableHeight()
    func sort() {
        self.view.isUserInteractionEnabled = false
        switchOffSortHeaders()
        guard let sched = self.schedule else {return}
        switch currentSort {
        case .Pasture:
            switchOnSortHeader(button: pasture)
            self.entries = sched.scheduleObjects.sorted(by: {$0.pasture?.name ?? "" <  $1.pasture?.name ?? ""})
        case .LiveStock:
            switchOnSortHeader(button: livestock)
            self.entries = sched.scheduleObjects.sorted(by: {$0.liveStockTypeId  <  $1.liveStockTypeId })
        case .DateIn:
            switchOnSortHeader(button: dateIn)
            self.entries = sched.scheduleObjects.sorted(by: {$0.dateIn ?? Date() <  $1.dateIn ?? Date()})
        case .DateOut:
            switchOnSortHeader(button: dateOut)
            self.entries = sched.scheduleObjects.sorted(by: {$0.dateOut ?? Date() <  $1.dateOut ?? Date()})
        case .Number:
            switchOnSortHeader(button: numAnimals)
            self.entries = sched.scheduleObjects.sorted(by: {$0.numberOfAnimals <  $1.numberOfAnimals})
        case .None:
            self.view.isUserInteractionEnabled = true
            return
        }
        self.tableView.reloadData()
        self.view.isUserInteractionEnabled = true
    }

    func clearSort() {
        self.currentSort = .None
    }
}

// MARK: Tableview
extension ScheduleViewController:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleFormTableViewCell")
        registerCell(name: "ScheduleObjectTableViewCell")
        registerCell(name: "ScheduleFooterTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleCell(indexPath: IndexPath) -> ScheduleFormTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleFormTableViewCell", for: indexPath) as! ScheduleFormTableViewCell
    }

    func getScheduleObjectCell(indexPath: IndexPath) -> ScheduleObjectTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleObjectTableViewCell", for: indexPath) as! ScheduleObjectTableViewCell
    }

    func getScheduleFooterCell(indexPath: IndexPath) -> ScheduleFooterTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleFooterTableViewCell", for: indexPath) as! ScheduleFooterTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getScheduleEntryCell(for: indexPath)
        } else {
            let cell = getScheduleFooterCell(indexPath: indexPath)
            cell.setup(mode: mode, schedule: schedule!, agreementID: (rup?.agreementId)!)
            self.footerReference = cell
            return cell
        }
    }

    func getScheduleEntryCell(for indexPath: IndexPath) ->  ScheduleObjectTableViewCell {
        let cell = getScheduleObjectCell(indexPath: indexPath)
        if let plan = self.rup, self.entries.count > indexPath.row {
            cell.setup(mode: mode, scheduleObject: self.entries[indexPath.row], rup: plan, scheduleViewReference: self)
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.entries.count
        } else {
            return 1
        }
    }
}
