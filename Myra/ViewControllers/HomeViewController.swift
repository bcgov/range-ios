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

class HomeViewController: BaseViewController {

    // MARK: Constants
    let reachability = Reachability()!

    // MARK: Variables

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

    /////// may need to remove ////////
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var createButton: UIButton!
    //////////////////////

    @IBOutlet weak var userBoxView: UIView!
    @IBOutlet weak var userBoxLabel: UILabel!

    @IBOutlet weak var connectivityLabel: UILabel!
    @IBOutlet weak var lastSyncLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    // sync
    @IBOutlet weak var syncButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncing = false
        loadHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachabilityNotification()
    }

    // MARK: Outlet actions
    @IBAction func CreateRUPAction(_ sender: Any) {
//        let agreements = RUPManager.shared.getAgreements()
        let vm = ViewManager()
        let vc = vm.selectAgreement
        vc.setup(callBack: { closed in
            self.loadHome()
        })
        self.present(vc, animated: true, completion: nil)
    }

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
        if lastSync != nil, let ls = lastSync?.string() {
            lastSyncLabel.text = ls
        } else {
            showLoginPage()
            authenticateIfRequred()
        }
        setUpTable()
        self.getRUPs()
        self.tableView.reloadData()
    }

    @IBAction func syncAction(_ sender: UIButton) {

        authenticateIfRequred()
    }

    @IBAction func syncPageButtonAction(_ sender: UIButton) {
        syncing = false
    }

    override func whenAuthenticated() {
        self.syncing = true
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
//        let syncView = getSyncView()
//        syncView.autoresizesSubviews = false
        self.view.addSubview(getSyncView())
    }

    func hideSyncPage() {
        syncButton.isUserInteractionEnabled = true
        self.createButton.isUserInteractionEnabled = true
        self.tableView.isUserInteractionEnabled = true
    }

    func showLoginPage() {

    }

    func hideLoginPage() {

    }

}

// Functions to handle TableView
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
        let cell = getAssignedRupCell(indexPath: indexPath)
        cell.set(rup: rups[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rups.count
    }
}

// Functions to handle retrival of rups
extension HomeViewController {

    func getRUPs()  {
        let rups = RUPManager.shared.getRUPs()
        // sort by last name
        self.rups = rups.sorted(by: { $0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName })
    }
}

// Functions to handle displaying views
extension HomeViewController {

    // returns rup details view controller
    func getRUPDetailsVC() -> RUPDetailsViewController {
         let vm = ViewManager()
        return vm.rupDetails
    }

    // present rup details in view mode
    func viewRUP(rup: RUP) {
        print("go to view")
        let vc = getRUPDetailsVC()
        vc.set(rup: rup, readOnly: true)
        self.present(vc, animated: true, completion: nil)
    }

    // present rup details in ammend mode
    func editRUP(rup: RUP) {
        let vm = ViewManager()
        let vc = vm.createRUP
        vc.setup(rup: rup) { (closed) in
            self.tableView.reloadData()
        }
        self.present(vc, animated: true, completion: nil)
    }

    func getMapVC() -> CreateViewController {
        let vm = ViewManager()
        return vm.create
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
            self.syncButton.alpha = 1
            syncButton.isEnabled = true
            self.connectivityLabel.text = "ONLINE MODE"
        } else {
            self.syncButton.alpha = 0
            syncButton.isEnabled = false
            self.connectivityLabel.text = "OFFLINE MODE"
        }
    }
}

// Styles
extension HomeViewController {
    func style() {
        setStatusBarAppearanceDark()
        makeCircle(view: userBoxView)
    }
}

