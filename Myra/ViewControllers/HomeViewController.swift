//
//  ViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Reachability

class HomeViewController: BaseViewController {

    // MARK: Constants
    let reachability = Reachability()!

    // MARK: Variables
    var rups: [RUP] = [RUP]()

    var online: Bool = false { didSet{ updateStatusText() }}

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

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        self.rups = getRUPs()
        setUpTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachabilityNotification()
    }

    // MARK: Outlet actions
    @IBAction func CreateRUPAction(_ sender: Any) {
        showCreate()
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
    // TODO: load from local storage instead.
    func getRUPs() -> [RUP] {
        let rups = RUPGenerator.shared.getSamples(number: 20)
        // sort by last name
        return rups.sorted(by: { $0.primaryAgreementHolderLastName < $1.primaryAgreementHolderLastName })
    }
}

// Functions to handle displaying views
extension HomeViewController {

    // returns rup details view controller
    func getRUPDetailsVC() -> RUPDetailsViewController {
        return ViewManager.shared.rupDetails
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
        return ViewManager.shared.create
    }

    func getCreateNewVC() -> CreateNewRUPViewController {
        return ViewManager.shared.createRUP
    }

    func showCreate() {
//        let vc = getCreateVC()
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

    func updateStatusText() {
        if online {
            self.connectivityLabel.text = "ONLINE MODE"
        } else {
            self.connectivityLabel.text = "OFFLINE MODE"
        }
    }
}

extension HomeViewController {
    func style() {
        makeCircle(view: userBoxView)
    }
}
