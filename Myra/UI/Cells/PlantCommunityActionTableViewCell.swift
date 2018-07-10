//
//  PlantCommunityActionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityActionTableViewCell: UITableViewCell {

    // Mark: Constants
    static let cellHeight = 255.0

    // MARK: Variables
    var mode: FormMode = .View
    var flag = false
    var action: PastureAction?

    // MARK: Outlets
    @IBOutlet weak var noGrazeSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var actionField: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func actionFieldAction(_ sender: UIButton) {
        guard let current = action else {return}
        let vm = ViewManager()
        let lookup = vm.lookup

        lookup.setup(objects: RUPManager.shared.getPastureActionLookup()) { (selected, selection) in
            lookup.dismiss(animated: true, completion: nil)
            if selected, let option = selection {
                current.action = option.display
                do {
                    let realm = try Realm()
                    try realm.write {
                        current.action = option.display
                    }
                    self.autoFill()
                } catch _ {
                    fatalError()
                }
            }
        }
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.showPopUp(vc: lookup, on: sender)


    }

    @IBAction func noGrazePeriodBegin(_ sender: UIButton) {

    }

    @IBAction func noGrazePeriodEnd(_ sender: UIButton) {

    }

    // MARK: Setup
    func setup(mode: FormMode, action: PastureAction) {
        self.mode = mode
        self.action = action

    }

    func autoFill() {
        guard let current = action else {return}
        self.actionField.text = current.action
        if current.action.lowercased() == "timing" {
            noGrazeSectionHeight.constant = 50
        } else {
            noGrazeSectionHeight.constant = 0
        }
    }

    func style() {
        
    }
    
}
