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
import MaterialShowcase
import Extended
import Cam
import CoreML

class HomeViewController: BaseViewController {

    // MARK: Constants
    let reachability = Reachability()!
    var syncButtonAnimationTag = 120
    var syncButtonActionTag = 121

    var blockSync = false

    // MARK: Variables
    var realmNotificationToken: NotificationToken?
    var parentReference: MainViewController?
    var rups: [Plan] = [Plan]()
    var expandIndexPath: IndexPath?

    var unstableConnection: Bool = false

    var online: Bool = false {
        didSet {
            updateAccordingToNetworkStatus()
        }
    }

    var syncing: Bool = false

    // Tourtip vars
//    var tours: [TourTip] = [TourTip]()

//    var lastTourTip: TourTip?
//    var lastTourTarget: UIView?
//    var lastTourTargetAlpha: CGFloat = 1
    var presentedAfterLogin: Bool = false

    var lastSyncLabelTimer = Timer()
    var lastSyncTimerActive = false

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
    @IBOutlet weak var tourTipButton: UIButton!

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
    @IBOutlet weak var filtersStack: UIStackView!

    // table
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderSeparator: UIView!

    // headers
    @IBOutlet weak var rangeNumberHeader: UILabel!
    @IBOutlet weak var agreementHolderHeader: UILabel!
    @IBOutlet weak var rangeNameHeader: UILabel!
    @IBOutlet weak var statusHeader: UILabel!

    // Tour
    @IBOutlet weak var endTourView: UIView!
    @IBOutlet weak var endTourLabel: UILabel!

    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        syncing = false
        loadHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachabilityNotification()
        self.removeDummy()
        self.getRUPs()
//        TileMaster.shared.downloadTilePathsForCenterAt(lat: 48.431695, lon: -123.369190)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.endChangeListener()
        self.lastSyncLabelTimer = Timer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if presentedAfterLogin {
            self.view.layoutIfNeeded()
            self.beginTour()
            self.presentedAfterLogin = false
        }
    }

    // MARK: Outlet actions
    @IBAction func endTour(_ sender: Any) {
        endTour()
    }

    @IBAction func testCam(_ sender: UIButton) {
//        Feedback.show(in: self)

//        let cam = Cam()
//        cam.display(on: self) { (photo) in
//            if let photo = photo {
//                Loading.shared.start()
//                let pic = RangePhoto()
//                pic.save(from: photo)
//                let preview: TagImage = TagImage.fromNib()
//                preview.show(with: pic, in: self, then: {})
//            }
//        }
    }

    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    @IBAction func tourAction(_ sender: UIButton) {
        let dialog: GetNameDialog = UIView.fromNib()
        dialog.initialize {
            self.beginTour()
        }

//        beginTourTip()

        /*
        let firstIndexPath = IndexPath(row: 0, section: 0)
        let tour = Tour()
        var objects: [TourObject] = [TourObject]()
        let createBtn = TourObject(header: "Create Button", desc: "When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.", on: createButton)
        let lsLabel = TourObject(header: "LastSync", desc: "When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.", on: lastSyncLabel)
        let smtnLabel = TourObject(header: "Light", desc: "When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.", on: connectivityLight)

        objects.append(lsLabel)
        objects.append(createBtn)
        objects.append(smtnLabel)

        if let visibles = self.tableView.indexPathsForVisibleRows{
            let lastVisible = visibles[visibles.count - 2]
            if let cellOne = self.tableView.cellForRow(at: lastVisible) {
                let celltuorial = TourObject(header: "Down below", desc: "When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.", on: cellOne)
                objects.append(celltuorial)
            }
        }
        if let cellOne = self.tableView.cellForRow(at: firstIndexPath) {
            let celltuorial = TourObject(header: "Range Use Plan", desc: "When you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.\nWhen you open the MyRange app you will be shown all of your assigned RUP’s on this homescreen. Tap on RUP’s to view them and their previous versions.", on: cellOne)
            objects.append(celltuorial)
        }

        tour.initialize(with: objects, backgroundColor: Colors.active.blue, textColor: UIColor.white, containerIn: self)
 */
    }

    @IBAction func createRUPAction(_ sender: UIButton) {
        guard let parent = self.parentReference else {return}
        parent.showCreateNew()
    }

    @IBAction func syncAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false

//        syncButtonLabel.alpha = 1
        blockSync = true
        showSyncMessage(text: "Connecting...", after: 0)
        if authServices.isAuthenticated() {
            playSyncButtonAnimation()
            animateIt()
            showSyncMessage(text: "Connection taking longer than expected...", after: 5)
            showSyncMessage(text: "Your connection is very unstable...", after: 10)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                self.stopSyncButtonAnimation()
                if self.blockSync == true {
                    self.showSyncMessage(text: "Cannot Sync at this time.", after: 0)
                    self.unstableConnection = true
                    sender.isUserInteractionEnabled = true
                }
            })
        } else {
            sender.isUserInteractionEnabled = true
        }
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
        if syncing {return}
        filterButtonOn(button: allFilter)
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
        updateLastSyncLabel()
        if let query = RealmRequests.getObject(SyncDate.self), let last = query.last {
            lastSyncLabel.text = last.timeSince()
            if !lastSyncTimerActive {
                lastSyncLabelTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateLastSyncLabel), userInfo: nil, repeats: true)
            }
        } else {
            authenticateIfRequred()
        }
        setUpTable()
        filterByAll()
        beginChangeListener()



    }

    @objc func updateLastSyncLabel() {
        if let query = RealmRequests.getObject(SyncDate.self), let last = query.last {
            lastSyncLabel.text = last.timeSince()
        }
    }

    func loadRUPs() {
        if syncing {return}
        RUPManager.shared.fixUnlinkedPlans()
        self.rups = [Plan]()
        self.tableView.reloadData()
        /*
         Clean up the local DB by removing plans that were created
         from agreements but cancelled.
         */
        RUPManager.shared.cleanPlans()
        let rups = RUPManager.shared.getRUPs()
        print("Loading \(rups.count) plans")
        let agreements = RUPManager.shared.getAgreements()
        for agreement in agreements where agreement.plans.count > 0 {
            if let p = agreement.getLatestPlan() {
                self.rups.append(p)
            }
        }
        self.expandIndexPath = nil
        self.tableView.reloadData()
        self.tableView.isScrollEnabled = true
        AutoSync.shared.autoSync()
    }

    /*
     Use this to reload content if changes to db occurred.
     Mainly intended for updating after a sync
     */
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
            if self.blockSync {
                Banner.shared.show(message: text)
            }
        })
    }

    override func onAuthenticationSuccess() {
        if unstableConnection {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.blockSync = false
                self.syncButton.isUserInteractionEnabled = true
                self.unstableConnection = false
                self.animateIt()
            })
            return
        } else {
            blockSync = false
            synchronize()
        }
    }

    override func onAuthenticationFail() {
        blockSync = false
        self.syncButton.isUserInteractionEnabled = true
    }

    func synchronize() {
        self.rups = [Plan]()
        self.tableView.reloadData()
        self.endChangeListener()
        self.syncing = true
        self.createButton.isUserInteractionEnabled = false
        self.tableView.isUserInteractionEnabled = false
        self.syncButton.isUserInteractionEnabled = false
        sync { (done) in
            self.syncing = false
            self.loadHome()
            self.createButton.isUserInteractionEnabled = true
            self.tableView.isUserInteractionEnabled = true
            self.syncButton.isUserInteractionEnabled = true
        }
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

    func reloadRupsIfInvalid() {
        if !rupsAreValid() {
            loadRUPs()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expandOrClose(at: indexPath)
    }

    func expandOrClose(at indexPath: IndexPath, fromTour: Bool = false) {
        if !fromTour {
            reloadRupsIfInvalid()
        }
        if expandIndexPath == nil {
            self.expandIndexPath = indexPath
            self.tableView.isScrollEnabled = false
            self.tableView.performBatchUpdates({
                self.reloadAllCellsExcept(at: [indexPath])
            }) { (done) in
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                // if indexpath is the last visible, scroll to bottom of it
                if let visible = self.tableView.indexPathsForVisibleRows, visible.last == indexPath {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        } else {
            self.tableView.performBatchUpdates({
                if let i = expandIndexPath {
                    let cell = self.tableView.cellForRow(at: i) as! AssignedRUPTableViewCell
                    cell.styleDefault()
                    self.expandIndexPath = nil
                    self.reloadAllCellsExcept(at: [indexPath])
                }
            }) { (done) in
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            self.tableView.isScrollEnabled = true
        }
    }

    func reloadAllCellsExcept(at exclude: [IndexPath]) {
        guard let all = self.tableView.indexPathsForVisibleRows else {return}

        for each in all where !exclude.contains(each) {
            self.tableView.reloadRows(at: [each], with: .fade)
        }
    }
}

// MARK: Functions to handle retrival of rups
extension HomeViewController {

    func getRUPs()  {
        removeDummy()
        loadRUPs()
        // sort by last name
        self.rups = rups.sorted(by: { $0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName })
        filterByAll()
    }
}

// MARK: Connectivity
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
        guard let reachability = note.object as? Reachability else {return}
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
        Feedback.initializeButton()
        if online {
            self.syncContainer.alpha = 1
            syncButton.isEnabled = true
            self.connectivityLabel.text = "Online Mode"
            self.connectivityLight.backgroundColor = UIColor.green
            AutoSync.shared.autoSync()
        } else {
            self.syncContainer.alpha = 0
            syncButton.isEnabled = false
            self.connectivityLabel.text = "Offline Mode"
            self.connectivityLight.backgroundColor = UIColor.red
            self.syncing = false
        }
    }
}

// MARK: TourTip
extension HomeViewController: MaterialShowcaseDelegate {

    func endTour() {
        updateAccordingToNetworkStatus()
        closeDummyPlanCell {
            self.removeDummy()
            self.getRUPs()
            Feedback.initializeButton()
            AutoSync.shared.endListener()
            AutoSync.shared.beginListener()

            self.endChangeListener()
            self.beginChangeListener()
            self.tourTipButton.isUserInteractionEnabled = true
        }

    }

    func beginTour() {
        self.tourTipButton.isUserInteractionEnabled = false
        endChangeListener()
        AutoSync.shared.endListener()
        setDummyPlan()
        Feedback.removeButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.expandDummyPlanCell {
                let indexpath = IndexPath(row: 1, section: 0)
                guard let cell = self.getDummyPlanCell(), let innerCell = cell.tableView.cellForRow(at: indexpath), let planCell = innerCell as? AssignedRUPVersionTableViewCell else {return}
                cell.layoutIfNeeded()

                let tour = Tour()
                var objects: [TourObject] = [TourObject]()

                objects.append(TourObject(header: TourMessages.Home.createNewPlan.title, desc: TourMessages.Home.createNewPlan.body, on: self.createButton))
                objects.append(TourObject(header: TourMessages.Home.filterRups.title, desc: TourMessages.Home.filterRups.body, on: self.filtersStack))

                if let cellViewButton = planCell.viewButton {
                    objects.append(TourObject(header: TourMessages.Home.editViewPlan.title, desc: TourMessages.Home.editViewPlan.body, on: cellViewButton))
                }

                if let statusText = planCell.status {
                    objects.append(TourObject(header: TourMessages.Home.planStatus.title, desc: TourMessages.Home.planStatus.body, on: statusText))
                }

                if let cellContainer = cell.container {
                    objects.append(TourObject(header: TourMessages.Home.latestPlan.title, desc: TourMessages.Home.latestPlan.body, on: cellContainer))
                }

                tour.initialize(with: objects, backgroundColor: Colors.active.blue, textColor: UIColor.white, containerIn: self, then: {
                    self.endTour()

                })
            }
        }
    }

    func setDummyPlan() {
        let agreement = Agreement()
        agreement.agreementId = "RAN000000"
        let plan = Plan()
        plan.ranNumber = 000000
        plan.rangeName = "Tour Range"
        plan.remoteId = -99
        plan.agreementId = agreement.agreementId
        plan.updateStatus(with: .Created)
        let client = Client()
        client.name = "Roop Jawl"
        client.clientTypeCode = "A"
        plan.clients.append(client)
        agreement.plans.append(plan)
        RealmRequests.saveObject(object: plan)
        RealmRequests.saveObject(object: agreement)
        self.rups.removeAll()
        self.rups.append(plan)
        self.expandIndexPath = nil
        self.tableView.reloadData()
    }

    func removeDummy() {
        for element in RUPManager.shared.getPlansWith(remoteId: -99) {
            RealmRequests.deleteObject(element)
        }

        for element in RUPManager.shared.getAgreements(with: "RAN000000") {
            RealmRequests.deleteObject(element)
        }
    }

    func getDummyPlanCell() -> AssignedRUPTableViewCell? {
        let indexpath = IndexPath(row: 0, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexpath), let assignedRupCell = cell as? AssignedRUPTableViewCell else {return nil}
        return assignedRupCell
    }


    func expandDummyPlanCell(then: @escaping () -> Void) {
        let indexpath = IndexPath(row: 0, section: 0)
        expandOrClose(at: indexpath, fromTour: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            return then()
        }
    }

    func closeDummyPlanCell(then: @escaping () -> Void) {
        let indexpath = IndexPath(row: 0, section: 0)
        expandOrClose(at: indexpath, fromTour: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            return then()
        }
    }
}


