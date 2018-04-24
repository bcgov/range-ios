//
//  PlantCommunityTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityTableViewCell: UITableViewCell {

    // Variables:
    var plantCommunity: PlantCommunity = PlantCommunity()
    var mode: FormMode = .Create
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // adds border
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setup(mode: FormMode, plantCommunity: PlantCommunity) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        setupNotifications()
        notifyReload()
    }

    func setupNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updatePastureCells, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .reload, object: nil)
    }
    @objc func doThisWhenNotify() { return }

    func notifPastureCells() {
        NotificationCenter.default.post(name: .updatePastureCells, object: self, userInfo: ["reload": true])
    }

    func notifyReload() {
         NotificationCenter.default.post(name: .reload, object: self, userInfo: ["reload": true])
    }
}

// styles
extension PlantCommunityTableViewCell {
    func style() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor


    }
}
