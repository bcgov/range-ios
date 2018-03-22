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
    let authServices: AuthServices = {
        return AuthServices(baseUrl: SingleSignOnConstants.SSO.baseUrl, redirectUri: SingleSignOnConstants.SSO.redirectUri,
                            clientId: SingleSignOnConstants.SSO.clientId, realm:SingleSignOnConstants.SSO.realmName,
                            idpHint: SingleSignOnConstants.SSO.idpHint)
    }()

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
    @IBOutlet weak var grayScreen: UIView!
    @IBOutlet weak var syncContainer: UIView!
    @IBOutlet weak var syncTitle: UILabel!
    @IBOutlet weak var syncPageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncing = false
        authenticateIfRequred()
        loadHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachabilityNotification()
    }

    // MARK: Outlet actions
    @IBAction func CreateRUPAction(_ sender: Any) {
        let agreements = RUPManager.shared.getAgreements()
        let vm = ViewManager()
        let vc = vm.selectAgreement
        vc.setup(rups: agreements, callBack: { closed in
            self.loadHome()
        })
        self.present(vc, animated: true, completion: nil)
    }

    func loadHome() {
        let lastSync = RealmManager.shared.getLastSyncDate()
        if lastSync != nil, let ls = lastSync?.string() {
            lastSyncLabel.text = ls
        }
        setUpTable()
        self.getRUPs()
        self.tableView.reloadData()
        style()
    }

    @IBAction func syncAction(_ sender: UIButton) {
        syncing = true
    }

    @IBAction func syncPageButtonAction(_ sender: UIButton) {
        syncing = false
    }

    func showSyncPage() {
        self.grayScreen.alpha = 1
        beginSync()
    }

    func hideSyncPage() {
        self.grayScreen.alpha = 0
    }

    func beginSync() {
        syncPageButton.setTitle("Synchronizing...", for: .normal)
        syncPageButton.isEnabled = false
        APIManager.sync(completion: { (done) in
            if done {
                self.syncPageButton.setTitle("Sync completed.", for: .normal)
                self.loadHome()
            } else {
                self.syncPageButton.setTitle("Sync failed", for: .normal)
            }
            self.syncPageButton.isEnabled = true

        }) { (progress) in
            self.syncTitle.text = progress
        }
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
    func ammendRUP(rup: RUP) {
        print("go to ammend")
        let vc = getRUPDetailsVC()
        vc.set(rup: rup, readOnly: false)
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

// Mark: Authentication
extension HomeViewController {

    private func authenticateIfRequred() {
        if !authServices.isAuthenticated() {
            let vc = authServices.viewController() { (credentials, error) in

                guard let _ = credentials, error == nil else {
                    let title = "Authentication"
                    let message = "Authentication didn't work. Please try again."

                    self.showAlert(with: title, message: message)

                    return
                }
//                self.confirmNetworkAvailabilityBeforUpload(handler: self.uploadHandler())
            }

            present(vc, animated: true, completion: nil)
        } else {
            authServices.refreshCredientials(completion: { (credentials: Credentials?, error: Error?) in
//                if let error = error, error == AuthenticationError.expired {
//                    let vc = self.authServices.viewController() { (credentials, error) in
//
//                        guard let _ = credentials, error == nil else {
//                            let title = "Authentication"
//                            let message = "Authentication didn't work. Please try again."
//
//                            self.showAlert(with: title, message: message)
//
//                            return
//                        }
//
////                        self.confirmNetworkAvailabilityBeforUpload(handler: self.uploadHandler())
//                    }
//
//                    self.present(vc, animated: true, completion: nil)
//                    return
//                }

//                self.confirmNetworkAvailabilityBeforUpload(handler: self.uploadHandler())
            })
        }
    }

}
extension HomeViewController {
    func style() {
        makeCircle(view: userBoxView)
    }
}

