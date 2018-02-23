//
//  PastureTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PastureTableViewCell: UITableViewCell {

    // Mark: Constants
    let plantCommunityCellHeight = 100

    // Mark: Variables
    var pasture: Pasture?
    var plantCommunities: [PlantCommunity] = [PlantCommunity]()

    // Mark: Outlets
    @IBOutlet weak var pastureNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    @IBOutlet weak var pastureNotesTextField: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        addBoarder()
    }

    func addBoarder() {
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 5
        containerView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // Mark: Outlet Actions
    @IBAction func addPlantCommunityAction(_ sender: Any) {

    }

    // Mark: Functions
    func srtup(pasture: Pasture) {
        self.plantCommunities = pasture.plantCommunities
    }

    func getCellHeight() -> CGSize {
        return self.frame.size
    }

    func updateTableHeight() {
        tableHeight.constant = CGFloat((plantCommunities.count) * plantCommunityCellHeight + 5)
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.tableView.reloadData()
    }
    
}

extension PastureTableViewCell : UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "RangeUseageYearTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getYearCell(indexPath: IndexPath) -> RangeUseageYearTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "RangeUseageYearTableViewCell", for: indexPath) as! RangeUseageYearTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getYearCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantCommunities.count
    }

}
