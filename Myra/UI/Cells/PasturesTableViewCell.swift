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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // Mark: Outlet actions
    @IBAction func addPastureAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.promptInput(title: "Pasture Name", accept: .String, taken: RUPManager.shared.getPastureNames(rup: rup)) { (done, name) in
            if done {
                let newPasture = Pasture()
                newPasture.name = name
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
                self.updateTableHeight()
            }
        }
    }

    // Mark: Functions
    override func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
        tableHeight.constant = computeHeight()
        setUpTable()
        style()
    }

    func updateTableHeight() {
        self.tableView.reloadData()
        tableView.layoutIfNeeded()
        tableHeight.constant = computeHeight()
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.realodAndGoTO(indexPath: parent.pasturesIndexPath)
    }

    func computeHeight() -> CGFloat {
        /*
         Height of Pastures cell =
        */
        var padding = 7
        var h: CGFloat = 0.0
        for pasture in (rup.pastures) {
            h = h + computePastureHeight(pasture: pasture) + 7
        }
        return h
    }

    func computePastureHeight(pasture: Pasture) -> CGFloat {
        // 395 is the right number but clearly needed more padding
//        let staticHeight: CGFloat = 395
        let staticHeight: CGFloat = 410
        let pastureHeight: CGFloat = 105
        return (staticHeight + pastureHeight * CGFloat(pasture.plantCommunities.count))
    }

    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        styleButton(button: addButton)
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

