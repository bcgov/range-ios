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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(mode: FormMode, plantCommunity: PlantCommunity) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        setupNotifications()

        let parent = self.parentViewController

        if !parent.reloading {
             notifPastureCells()
        } else {
            parent.reloading = false
        }
    }

    func setupNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .updatePastureCells, object: nil)
    }
    @objc func doThisWhenNotify() { return }

    func notifPastureCells() {
        NotificationCenter.default.post(name: .updatePastureCells, object: self, userInfo: ["reload": true])
    }
}
