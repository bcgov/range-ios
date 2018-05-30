//
//  SelectionPopUpViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectionPopUpViewController: UIViewController, Theme {

    // MARK: Constants
    let cellHeight: CGFloat = 33
    let buttonHeight: CGFloat = 42
    
    // MARK: Variables
    var objects: [SelectionPopUpObject] = [SelectionPopUpObject]()
    var completion: ((_ done: Bool,_ result: SelectionPopUpObject?) -> Void )?
    var multiCompletion: ((_ done: Bool,_ result: [SelectionPopUpObject]?) -> Void )?
    var multiSelect: Bool = false
    var selectedIndexes: [Int] = [Int]()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectButtonHeight: NSLayoutConstraint!

    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        style()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        if let callback = completion {
            return callback(false, nil)
        }
    }

    @IBAction func selectAction(_ sender: UIButton) {
        sendBack()
    }

    func sendBack() {
        guard let callback = multiCompletion else {return}
        var selected = [SelectionPopUpObject]()
        for i in selectedIndexes {
            selected.append(objects[i])
        }
        return callback(true, selected)
    }

    // MARK: Functions
    // MARK: Setup
    func setup(objects: [SelectionPopUpObject], completion: @escaping (_ done: Bool,_ result: SelectionPopUpObject?) -> Void) {
        self.completion = completion
        self.objects = objects
        setupTable()
    }

    func setup(multiSelect: Bool, selected: [SelectionPopUpObject],objects: [SelectionPopUpObject], completion: @escaping (_ done: Bool,_ result: [SelectionPopUpObject]?) -> Void) {
        self.multiSelect = multiSelect
        self.multiCompletion = completion
        self.objects = objects

        // find already selected indexes
        for (index,element) in objects.enumerated() {
            for item in selected where element.value == item.value {
                selectedIndexes.append(index)
            }
        }
        setupTable()
    }

    func getEstimatedHeight() -> Int {
        // top and bottom padding in cell
        let padding = 20
        if objects.count == 0 {return 20}
        var total = (objects.count * Int(cellHeight)) + (objects.count * padding)
        if multiSelect {
            // add button height
            total += Int(buttonHeight)
        }
        return total
    }

    func canDisplayFullContentIn(height: Int) -> Bool {
        return getEstimatedHeight() <= height
    }

    // MARK: Style
    func style() {
        guard let btnHeight = selectButtonHeight else {return}
        if multiSelect {
            btnHeight.constant = buttonHeight
            styleFillButton(button: selectButton)
        } else {
            btnHeight.constant = 0
            selectButton.alpha = 0
        }
    }
}

// MARK: TableView
extension SelectionPopUpViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "selectionPopUpTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> selectionPopUpTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "selectionPopUpTableViewCell", for: indexPath) as! selectionPopUpTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var color = Colors.oddCell
        if indexPath.row % 2 == 0 {
            color = Colors.evenCell
        }
        let cell = getCell(indexPath: indexPath)
        cell.setup(object: objects[indexPath.row], bg: color)
        // if element should be selected
        if multiSelect{
            if selectedIndexes.contains(indexPath.row) {
                cell.select()
            } else {
                cell.deSelect()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if multi select is not enabled, return selection
        if !multiSelect {
            guard let callback = completion else {return}
            return callback(true, objects[indexPath.row])
        } else {
            // if is already selected
            if selectedIndexes.contains(indexPath.row) {
                // deselect
                guard let index = selectedIndexes.index(of: indexPath.row) else {return}
                selectedIndexes.remove(at: index)
            } else {
                // select
                selectedIndexes.append(indexPath.row)
            }
            self.tableView.reloadData()
        }
    }

}
