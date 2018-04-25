//
//  SelectAgreementViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectAgreementViewController: UIViewController {

    var parentCallBack: ((_ close: Bool) -> Void )?

    var agreements: [Agreement] = [Agreement]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.agreements = RUPManager.shared.getAgreementsWithNoRUPs()
        setUpTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.parentCallBack != nil {
                return self.parentCallBack!(true)
            }
        })
    }

    func setup(callBack: @escaping ((_ close: Bool) -> Void )) {
        self.parentCallBack = callBack
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
        return agreements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.setup(agreement: agreements[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rup = RUPManager.shared.genRUP(forAgreement: agreements[indexPath.row])
        let vm = ViewManager()
        let createVC = vm.createRUP
        createVC.setup(rup: rup, callBack: {closed in
            self.dismiss(animated: true, completion: {
                if self.parentCallBack != nil {
                    return self.parentCallBack!(true)
                }
            })
        })
        self.present(createVC, animated: true, completion: nil)
    }

}

