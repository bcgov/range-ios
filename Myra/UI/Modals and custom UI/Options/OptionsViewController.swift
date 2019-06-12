//
//  OptionsViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    // MARK: Constants
    let optionsCellName = "OptionsTableViewCell"
    let cellHeight: CGFloat = 45
    let suggestedWidth = 280

    // MARK: Variables
    var options: [Option] = [Option]()
    var completion: ((_ option: Option) -> Void )?
    var suggestedHeight = 0

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    // MARK: Functions

//    // MARK: Setup
//    func setup(options: [Option], completion: @escaping (_ option: Option) -> Void) {
//        self.options = options
//        self.completion = completion
//        setupTable()
//        estimateHeight()
//    }

    // MARK: Setup
    func setup(options: [Option], onVC: BaseViewController, onButton: UIButton, completion: @escaping (_ option: Option) -> Void) {
        self.options = options
        self.completion = completion
        setupTable()
        estimateHeight()
        onVC.showPopOver(on: onButton , vc: self, height: suggestedHeight, width: suggestedWidth, arrowColor: nil)
    }

    func estimateHeight() {
        let paddingInCell = 10
        self.suggestedHeight = ((options.count * Int(cellHeight)) + (options.count * paddingInCell))
    }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: optionsCellName)
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> OptionsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: optionsCellName, for: indexPath) as! OptionsTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var color = Colors.oddCell
//        if indexPath.row % 2 == 0 {
//            color = Colors.evenCell
//        }
        let cell = getCell(indexPath: indexPath)
        cell.setup(option: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let callBack = completion {
            self.dismiss(animated: true) {
                 return callBack(self.options[indexPath.row])
            }
        }
    }
}
