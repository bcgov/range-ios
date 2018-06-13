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
        authenticateIfRequred()
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
        loadRUPs()
        filterButtonOn(button: allFilter)
        self.rups = RUPManager.shared.getRUPs()
        sortByRangeNumber()
        self.tableView.reloadData()
    }

    func filterByDrafts() {
        loadRUPs()
        filterButtonOn(button: draftsFilter)
        self.rups = RUPManager.shared.getDraftRups()
        self.tableView.reloadData()
    }

    func filterByPending() {
        loadRUPs()
        filterButtonOn(button: pendingFilter)
        self.rups = RUPManager.shared.getPendingRups()
        self.tableView.reloadData()
    }

    func filterByCompleted() {
        loadRUPs()
        filterButtonOn(button: completedFilter)
        self.rups = RUPManager.shared.getCompletedRups()
        self.tableView.reloadData()
    }

    func sortByAgreementHolder() {
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName})
    }

    func sortByRangeName() {
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.rangeName < $1.rangeName})
    }

    func sortByStatus() {
        loadRUPs()
        self.rups = self.rups.sorted(by: {$0.getStatus().rawValue < $1.getStatus().rawValue})
    }

    func sortByRangeNumber() {
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
            let components = calendar.dateComponents([.day], from: ls, to: now)
            if let days = components.day {
                lastSyncLabel.text = "\(days) days ago"
            } else {
                lastSyncLabel.text = "Unknown"
            }
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
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("change observed")
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
            print("Stopped Listening :(")
        }
    }

    func loadRUPs() {
        let plans = RUPManager.shared.getRUPs()
        /*
         Clean up the local DB by removing plans that were created
         from agreements but cancelled.
        */
        for plan in plans where plan.isNew {
            RealmRequests.deleteObject(plan)
        }
        self.rups = RUPManager.shared.getRUPs()
    }

    // MARK: Styles
    func style() {
        setStatusBarAppearanceLight()
        styleNavBar()
        styleCreateButton()
        styleFilterContainer()
        styleUserBox()
        makeCircle(view: connectivityLight)
        setFilterButtonFonts()
        tableHeaderSeparator.backgroundColor = Colors.secondary
        styleSyncBox()
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
        viewTitle.font = Fonts.getPrimaryHeavy(size: 40)
    }

    func styleCreateButton() {
        styleFillButton(button: createButton)
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
        allFilter.titleLabel?.font = Fonts.getPrimaryMedium(size: 17)
        draftsFilter.titleLabel?.font = Fonts.getPrimaryMedium(size: 17)
        pendingFilter.titleLabel?.font = Fonts.getPrimaryMedium(size: 17)
        completedFilter.titleLabel?.font = Fonts.getPrimaryMedium(size: 17)
    }

    // MARK: Sync
    override func whenAuthenticated() {
        self.syncing = true
        self.endChangeListener()
        sync { (synced) in
            self.loadHome()
        }
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
        syncButton.isUserInteractionEnabled = true
        self.createButton.isUserInteractionEnabled = true
        self.tableView.isUserInteractionEnabled = true
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
        if index % 2 == 0 {
            cell.setup(rup: rups[index], color: Colors.evenCell)
        } else {
            cell.setup(rup: rups[index], color: Colors.oddCell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rups.count
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
            self.connectivityLabel.text = "ONLINE MODE"
            self.connectivityLight.backgroundColor = UIColor.green
            DataServices.shared.autoSync()
        } else {
            self.syncContainer.alpha = 0
            syncButton.isEnabled = false
            self.connectivityLabel.text = "OFFLINE MODE"
            self.connectivityLight.backgroundColor = UIColor.red
        }
    }
}


