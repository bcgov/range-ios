//
//  SelectAgreementViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectAgreementViewController: UIViewController {

    var rups: [RUP] = [RUP]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func setup(rups: [RUP]) {
        self.rups = rups
        self.setUpTable()
    }

    func reload() {
        APIManager.getDummyRUPs { (done, rups) in
            if done {
                self.rups = rups!
                self.tableView.reloadData()
            }
        }
    }
}

extension SelectAgreementViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AgreementTableViewCell")
    }
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> AgreementTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AgreementTableViewCell", for: indexPath) as! AgreementTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.setup(rup: rups[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rup = rups[indexPath.row]
         let vm = ViewManager()
        let createVC = vm.createRUP
        createVC.setup(rup: rup)
        self.present(createVC, animated: true, completion: nil)
    }

}

