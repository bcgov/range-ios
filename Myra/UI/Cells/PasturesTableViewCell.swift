//
//  PasturesTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

/*
 Pastures uses a different logic than range years cell for height:
 the height of pasture cells within the table view depends on the height
 of the content of a pasture's conent which will be unpredictable.
*/
class PasturesTableViewCell: BaseFormCell {

    // Mark: Variables

    // Mark: Outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    // Mark: Outlet actions
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: tooltipPasturesTitle, desc: tooltipPasturesDescription)
    }

    @IBAction func addPastureAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        let vm = ViewManager()
        let textEntry = vm.textEntry
        textEntry.taken = Options.shared.getPastureNames(rup: rup)
        textEntry.setup(on: parent, header: "Pasture") { (accepted, value) in
            if accepted {
                let newPasture = Pasture()
                newPasture.name = value
                do {
                    let realm = try Realm()
                    let aRup = realm.objects(RUP.self).filter("localId = %@", self.rup.localId).first!
                    try realm.write {
                        aRup.pastures.append(newPasture)
                        realm.add(newPasture)
                    }
                    self.rup = aRup
                } catch _ {
                    fatalError()
                }
                self.updateTableHeight(newAdded: true)
            }
        }
    }

    // Mark: Functions
    override func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
        switch mode {
        case .View:
            addButton.isEnabled = false
            addButton.alpha = 0
        case .Edit:
            addButton.isEnabled = true
            addButton.alpha = 1
        }
        tableHeight.constant = computeHeight()
        setUpTable()
        style()
    }

    func updateTableHeight(newAdded: Bool? = false) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableHeight.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

    func computeHeight() -> CGFloat {
        /*
         Height of Pastures cell =
        */
        let padding: CGFloat = 5
        var h: CGFloat = 0.0
        for pasture in (rup.pastures) {
            h = h + computePastureHeight(pasture: pasture) + padding
        }
        return h
    }

    func computePastureHeight(pasture: Pasture) -> CGFloat {
        let staticHeight: CGFloat = 442
        let plantCommunityHeight: CGFloat = CGFloat(PlantCommunityTableViewCell.cellHeight)
        return (staticHeight + plantCommunityHeight * CGFloat(pasture.plantCommunities.count))
    }

    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        styleHollowButton(button: addButton)
    }
    
}

// TableView
extension PasturesTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PastureTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getYearCell(indexPath: IndexPath) -> PastureTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PastureTableViewCell", for: indexPath) as! PastureTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getYearCell(indexPath: indexPath)
        if (rup.pastures.count) <= indexPath.row {return cell}
        cell.setup(mode: mode, pasture: (rup.pastures[indexPath.row]), pastures: self)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rup.pastures.count)
    }

}

// Notifications
extension PasturesTableViewCell {
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .updatePasturesCell, object: nil, queue: nil, using: catchAction)
    }

    func catchAction(notification:Notification) {
        self.updateTableHeight()
    }

    func catchUpdateAction(notification:Notification) {
        self.updateTableHeight()
    }
}

