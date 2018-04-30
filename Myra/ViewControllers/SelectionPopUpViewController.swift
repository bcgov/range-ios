//
//  SelectionPopUpViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectionPopUpViewController: UIViewController {

    // MARK: Constants
    let cellHeight: CGFloat = 33
    
    // MARK: Variables
    var objects: [SelectionPopUpObject] = [SelectionPopUpObject]()
    var completion: ((_ done: Bool,_ result: SelectionPopUpObject?) -> Void )?

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeAction(_ sender: Any) {
        return completion!(false, nil)
    }

    func setup(objects: [SelectionPopUpObject], completion: @escaping (_ done: Bool,_ result: SelectionPopUpObject?) -> Void) {
        self.completion = completion
        self.objects = objects
        setupTable()
    }

    func getEstimatedHeight() -> Int {
        // top and bottom padding in cell
        let padding = 20
        print(cellHeight)
        return (objects.count * Int(cellHeight)) + (objects.count * padding)
    }

    func canDisplayFullContentIn(height: Int) -> Bool {
        return getEstimatedHeight() <= height
    }
}
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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return completion!(true, objects[indexPath.row])
    }

}
