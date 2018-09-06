//
//  ViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Reachability
import SingleSignOn
import Lottie
import RealmSwift
import Realm

class HomeViewController: BaseViewController {

    // MARK: Constants
    let reachability = Reachability()!
    var syncButtonAnimationTag = 120
    var syncButtonActionTag = 121

    // MARK: Variables
    var realmNotificationToken: NotificationToken?
    var parentReference: MainViewController?
    var rups: [RUP] = [RUP]()
    var expandIndexPath: IndexPath?

    var unstableConnection: Bool = false

    var online: Bool = false {
        didSet {
            updateAccordingToNetworkStatus()
        }
    }

    var syncing: Bool = false {
        didSet {
            if syncing {
                showSyncPage()
            } else {
                hideSyncPage()
            }
        }
    }

    // MARK: Outlets
    @IBOutlet weak var containerView: UIView!

    // Top
    @IBOutlet weak var userBoxView: UIView!
    @IBOutlet weak var userBoxLabel: UILabel!
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var navBarImage: UIImageView!
    @IBOutlet weak var syncButtonLabel: UILabel!
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var connectivityLabel: UILabel!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var connectivityLight: UIView!

    // sync
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var syncContainer: UIView!

    // Create button and filters
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var allFilter: UIButton!
    @IBOutlet weak var draftsFilter: UIButton!
    @IBOutlet weak var pendingFilter: UIButton!
    @IBOutlet weak var completedFilter: UIButton!

    // table
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderSeparator: UIView!

    // headers
    @IBOutlet weak var rangeNumberHeader: UILabel!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var rangeNameHeader: UILabel!
    @IBOutlet weak var statusHeader: UILabel!


    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        syncing = false
        loadHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachabilityNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.endChangeListener()
    }

    // MARK: Outlet actions
    @IBAction func createRUPAction(_ sender: UIButton) {
        let vm = ViewManager()
        let vc = vm.selectAgreement
        vc.setup(callBack: { closed in
            self.loadHome()
        })
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func syncAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        syncButtonLabel.alpha = 1
        syncButtonLabel.text = "Connecting..."
        animateIt()
        showSyncMessage(text: "Connection taking longer than expected...", after: 5)
        showSyncMessage(text: "Your connection is very unstable...", after: 10)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            if self.syncButtonLabel.alpha == 1 {
                self.unstableConnection = true
            }
        })
        authenticateIfRequred()
    }

    @objc override func syncEnd() {
        self.filterByAll()
    }

    @IBAction func filterAction(_ sender: UIButton) {
        switch sender {
        case allFilter:
             filterByAll()
        case draftsFilter:
            filterByDrafts()
        case pendingFilter:
             filterByPending()
        case completedFilter:
            filterByCompleted()
        default:
            print("not possible.. why would you link anything else to this?")
        }
    }

    @IBAction func userAction(_ sender: UIButton) {
        showLogoutOption(on: sender)
    }

    // MARK: Filter
    func filterByAll() {
        if syncing {return}
        filterButtonOn(button: allFilter)
//        loadRUPs()
        sortByRangeNumber()
        self.tableView.reloadData()
    }

    func filterByDrafts() {
        if syncing {return}
        loadRUPs()
        filterButtonOn(button: draftsFilter)
        let staffDraft = RUPManager.shared.getStaffDraftRups()
        self.rups = RUPManager.shared.getDraftRups()
        self.rups.append(contentsOf: staffDraft)
        self.tableView.reloadData()
    }

    func filterByPending() {
        if syncing {return}
        loadRUPs()
        filterButtonOn(button: pendingFilter)
        self.rups = RUPManager.shared.getPendingRups()
        self.tableView.reloadData()
    }

    func filterByCompleted() {
        if syncing {return}
        loadRUPs()
        filterButtonOn(button: completedFilter)
        self.rups = RUPManager.shared.getCompletedRups()
        self.tableView.reloadData()
    }

    func sortByAgreementHolder() {
        if syncing {return}
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName})
    }

    func sortByRangeName() {
        if syncing {return}
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.rangeName < $1.rangeName})
    }

    func sortByStatus() {
        if syncing {return}
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.getStatus().rawValue < $1.getStatus().rawValue})
    }

    func sortByRangeNumber() {
        if syncing {return}
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.ranNumber < $1.ranNumber})
    }

    // MARK: setup
    /*
     When loading home page,

     1) check if a last sync date exists.
     if not, show login page
     else, set last sync date label
     2) setup table view
     3) get rups that dont have status: Agreeemnt
     4) reload table to load the rups from step 3
     */

    func loadHome() {
        style()
        let lastSync = RealmManager.shared.getLastSyncDate()
        if let ls = lastSync {
            let calendar = Calendar.current
            let now = Date()
            let timeInterval = now.timeIntervalSince(ls)

            let hours = timeInterval.hours
            let minutes = timeInterval.minutes
            let seconds = timeInterval.seconds

            var lastSyncText = "Unknown"

            if hours < 1 {
                if minutes < 1 {
                    // show seconds
                    lastSyncText = "\(seconds) seconds ago"
                } else {
                    // show minutes
                    if minutes == 1 {
                        lastSyncText = "\(minutes) minute ago"
                    } else {
                        lastSyncText = "\(minutes) minutes ago"
                    }
                }
            } else {
                if hours > 24 {
                    // show days
                    let components = calendar.dateComponents([.day], from: ls, to: now)
                    if let days = components.day {
                        if days == 1 {
                            lastSyncText = "\(days) day ago"
                        } else {
                            lastSyncText = "\(days) days ago"
                        }
                    }
                } else {
                    // show hours
                    if hours == 1  {
                        if minutes == 1 {
                            lastSyncText = "\(hours) hour and \(minutes) minute ago"
                        } else {
                            lastSyncText = "\(hours) hour and \(minutes) minutes ago"
                        }
                    } else {
                        if minutes == 1 {
                            lastSyncText = "\(hours) hours and \(minutes) minute ago"
                        } else {
                            lastSyncText = "\(hours) hours and \(minutes) minutes ago"
                        }
                    }
                }
            }

            lastSyncLabel.text = lastSyncText

//            let components = calendar.dateComponents([.day], from: ls, to: now)
//            if let days = components.day {
//                lastSyncLabel.text = "\(days) days ago"
//            } else {
//                lastSyncLabel.text = "Unknown"
//            }
        } else {
            authenticateIfRequred()
        }
        setUpTable()
        filterByAll()
        beginChangeListener()
    }

    func beginChangeListener() {
        // Listener used for autosync:
        // If db has changed in this view, there probably was an autosync.
        print("Listening to db changes in HomeVC!")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("change observed in homeVC")
                self.loadRUPs()
                self.tableView.reloadData()
            }
        } catch _ {
            fatalError()
        }
    }

    func endChangeListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            print("Stopped Listening in homeVC:(")
        }
    }

    func loadRUPs() {
        if syncing {return}
//        DispatchQueue.main.async {
        self.rups = [RUP]()
        self.tableView.reloadData()
            /*
             Clean up the local DB by removing plans that were created
             from agreements but cancelled.
             */
            RUPManager.shared.cleanPlans()
            let rups = RUPManager.shared.getRUPs()
            print(rups.count)
            let agreements = RUPManager.shared.getAgreements()
            for agreement in agreements where agreement.rups.count > 0 {
                if let p = agreement.getLatestPlan() {
                    self.rups.append(p)
                }
            }
            self.tableView.reloadData()
//        }
    }

    // MARK: Styles
    func style() {
        setStatusBarAppearanceLight()
        styleNavBar()
        styleFillButton(button: createButton)
        styleFilterContainer()
        styleUserBox()
        makeCircle(view: connectivityLight)
        setFilterButtonFonts()
        tableHeaderSeparator.backgroundColor = Colors.secondary
        styleSyncBox()
        styleHeaders()
    }

    func styleHeaders() {
        styleTableColumnHeader(label: rangeNumberHeader)
        styleTableColumnHeader(label: agreementHolderHeader)
        styleTableColumnHeader(label: rangeNameHeader)
        styleTableColumnHeader(label: statusHeader)
    }

    func styleNavBar() {
        // lower alpha to show image behind
        statusBar.alpha = 0.8
        navBar.alpha = 0.8

        navBarImage.image = #imageLiteral(resourceName: "homeNavBarImage")

        // background color
        statusBar.backgroundColor = Colors.primary
        navBar.backgroundColor = Colors.primary

        // text colors
        syncLabel.textColor = UIColor.white
        connectivityLabel.textColor = UIColor.white
        lastSyncLabel.textColor = UIColor.white
        viewTitle.textColor = UIColor.white

        // fonts
        syncLabel.font = Fonts.getPrimary(size: 15)
        connectivityLabel.font = Fonts.getPrimary(size: 15)
        lastSyncLabel.font = Fonts.getPrimary(size: 15)
        viewTitle.font = Fonts.getPrimaryBold(size: 40)
        viewTitle.change(kernValue: -0.32)
    }

    func styleFilterContainer() {
        topContainer.backgroundColor = UIColor.white
        addShadow(to: topContainer.layer, opacity: 0.5, height: 1)
    }

    func styleUserBox() {
        makeCircle(view: userBoxView)
        userBoxView.backgroundColor = UIColor.white
        userBoxLabel.textColor = Colors.mainText
    }

    func styleSyncBox() {
        makeCircle(view: syncContainer)
        syncContainer.backgroundColor = UIColor.white

        // if animation exists, play.
        if let animation = self.view.viewWithTag(syncButtonAnimationTag) as? LOTAnimationView {
            animation.loopAnimation = false
            animation.play()
        } else {
            // add animated image
            let animatedSync = LOTAnimationView(name: "sync_icon")
            animatedSync.frame = syncContainer.frame
            animatedSync.center.y = syncButton.center.y
            animatedSync.center.x = syncButton.center.x
            animatedSync.contentMode = .scaleAspectFit
            animatedSync.loopAnimation = false
            animatedSync.tag = syncButtonAnimationTag
            self.syncContainer.addSubview(animatedSync)
            animatedSync.play()
        }

        // Note: now animation overlaps button.. so move the button to top
        if let button = self.view.viewWithTag(syncButtonActionTag) {
            self.syncContainer.addSubview(button)
        }
    }

    func playSyncButtonAnimation() {
        if let animation = self.view.viewWithTag(syncButtonAnimationTag) as? LOTAnimationView {
            animation.loopAnimation = true
            animation.play()
        }
    }

    func stopSyncButtonAnimation() {
        if let animation = self.view.viewWithTag(syncButtonAnimationTag) as? LOTAnimationView {
            animation.stop()
        }
    }

    func filterButtonOn(button: UIButton) {
        swtichFilterButtonsOff()
        button.setTitleColor(Colors.secondary, for: .normal)
    }

    func filterButtonOff(button: UIButton) {
        button.setTitleColor(Colors.bodyText, for: .normal)
        button.titleLabel?.font = Fonts.getPrimaryMedium(size: 17)
    }

    func swtichFilterButtonsOff() {
        filterButtonOff(button: allFilter)
        filterButtonOff(button: draftsFilter)
        filterButtonOff(button: pendingFilter)
        filterButtonOff(button: completedFilter)
    }

    func setFilterButtonFonts() {
        styleFilter(label: allFilter.titleLabel!)
        styleFilter(label: draftsFilter.titleLabel!)
        styleFilter(label: pendingFilter.titleLabel!)
        styleFilter(label: completedFilter.titleLabel!)
    }

    // MARK: Sync
    func showSyncMessage(text: String, after: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: {
            self.syncButtonLabel.text = text
            self.animateIt()
        })
    }

    override func onAuthenticationSuccess() {
        print(APIManager.headers())
        if unstableConnection {
            syncButtonLabel.text = "Connections is not stable for enough for a full sync"
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.syncButtonLabel.alpha = 0
                self.syncButton.isUserInteractionEnabled = true
                self.unstableConnection = false
                self.animateIt()
            })
            return
        }
        self.syncButtonLabel.alpha = 0
        self.syncing = true
        self.endChangeListener()
        sync { (synced) in
            self.loadHome()
        }
    }

    override func onAuthenticationFail() {
        self.syncButtonLabel.alpha = 0
        self.syncButton.isUserInteractionEnabled = true
    }

    override func whenSyncClosed() {
        self.syncing = false
    }

    func showSyncPage() {
        syncButton.isUserInteractionEnabled = false
        self.createButton.isUserInteractionEnabled = false
        self.tableView.isUserInteractionEnabled = false
        self.view.addSubview(getSyncView())
    }

    func hideSyncPage() {
        removeSyncPage()
        self.createButton.isUserInteractionEnabled = true
        self.tableView.isUserInteractionEnabled = true
        syncButton.isUserInteractionEnabled = true
    }

    override func syncActionButtonPressed() {
//        getRUPs()
//        self.tableView.reloadData()
        filterByAll()
    }
}

// MARK: TableView functions
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AssignedRUPTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getAssignedRupCell(indexPath: IndexPath) -> AssignedRUPTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AssignedRUPTableViewCell", for: indexPath) as! AssignedRUPTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = getAssignedRupCell(indexPath: indexPath)
        var expandFlag: Bool? = nil
        if let selectedIndex = self.expandIndexPath {
            if selectedIndex == indexPath {
                expandFlag = true
            } else {
                expandFlag = false
            }
        }
        if index % 2 == 0 {
            cell.setup(rup: rups[index], color: Colors.evenCell, expand: expandFlag)
        } else {
            cell.setup(rup: rups[index], color: Colors.oddCell, expand: expandFlag)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rups.count
    }

    func rupsAreValid() -> Bool {
        for element in self.rups {
            if element.isInvalidated {
                return false
            }
        }
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !rupsAreValid() {
            loadRUPs()
        }
        if !rupsAreValid() {
            return
        }
        if expandIndexPath == nil {
            self.expandIndexPath = indexPath
            self.tableView.isScrollEnabled = false
            if #available(iOS 11.0, *) {
                self.tableView.performBatchUpdates({
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }) { (done) in
                    self.tableView.reloadData()
                    // if indexpath is the last visible, scroll to bottom of it
                    if let visible = tableView.indexPathsForVisibleRows, visible.last == indexPath {
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            } else {
                // PRE ios 11
               self.tableView.reloadData()
                // if indexpath is the last visible, scroll to bottom of it
                if let visible = tableView.indexPathsForVisibleRows, visible.last == indexPath {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        } else {
            if #available(iOS 11.0, *) {
                self.tableView.performBatchUpdates({
                    if let i = expandIndexPath {
                        let cell = self.tableView.cellForRow(at: i) as! AssignedRUPTableViewCell
                        cell.styleDefault()
                        self.expandIndexPath = nil
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }) { (done) in
                    self.tableView.reloadData()
                }
            } else {
                 self.expandIndexPath = nil
                self.tableView.reloadData()
            }
            self.tableView.isScrollEnabled = true
        }
    }
}

// Functions to handle retrival of rups
extension HomeViewController {

    func getRUPs()  {
        loadRUPs()
        // sort by last name
        self.rups = rups.sorted(by: { $0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName })
        filterByAll()
    }
}

// Functions to handle displaying views
extension HomeViewController {

    func editRUP(rup: RUP) {
        let vc = getCreateNewVC()
        vc.setup(rup: rup, mode: .Edit) { closed, cancel  in
            self.getRUPs()
        }
        self.present(vc, animated: true, completion: nil)
    }

    func viewRUP(rup: RUP) {
        let vc = getCreateNewVC()
        vc.setup(rup: rup, mode: .View) { closed, cancel in
            self.tableView.reloadData()
        }
        self.present(vc, animated: true, completion: nil)
    }

    func getCreateNewVC() -> CreateNewRUPViewController {
        let vm = ViewManager()
        return vm.createRUP
    }

    func showCreate() {
        let vc = getCreateNewVC()
        self.present(vc, animated: true, completion: nil)
    }
}

// Connectivity
extension HomeViewController {
    func setupReachabilityNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            online = true
        case .cellular:
            online = true
        case .none:
            online = false
        }
    }

    func updateAccordingToNetworkStatus() {
        if online {
            self.syncContainer.alpha = 1
            syncButton.isEnabled = true
            self.connectivityLabel.text = "Online Mode"
            self.connectivityLight.backgroundColor = UIColor.green
            DataServices.shared.autoSync()
        } else {
            self.syncContainer.alpha = 0
            syncButton.isEnabled = false
            self.connectivityLabel.text = "Offline Mode"
            self.connectivityLight.backgroundColor = UIColor.red
            self.syncing = false
        }
    }
}


