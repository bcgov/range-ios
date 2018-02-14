//
//  ViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Variables
    var rups: [RUP] = [RUP]()

    // MARK: Outlets
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rups = getRUPs()
        setUpTable()
    }

}

// Functions to handle retrival of rups
extension HomeViewController {
    // TODO: load from local storage instead
    func getRUPs() -> [RUP] {
        return RUPGenerator.shared.getSamples(number: 10)
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

// Functions to handle displaying views
extension HomeViewController {

    func getRUPDetailsVC() -> RUPDetailsViewController {
        return ViewManager.shared.rupDetails
    }
    func viewRUP(rup: RUP) {
        print("go to view")
        let vc = getRUPDetailsVC()
        vc.set(rup: rup, readOnly: true)
        self.present(vc, animated: true, completion: nil)
    }

    func amendRUP(rup: RUP) {
        print("go to ammend")
        let vc = getRUPDetailsVC()
        vc.set(rup: rup, readOnly: false)
        self.present(vc, animated: true, completion: nil)
    }

    
}
