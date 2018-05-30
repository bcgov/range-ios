//
//  PlantCommunityTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityTableViewCell: BaseFormCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    

    // Variables:
    var plantCommunity: PlantCommunity = PlantCommunity()
    override func awakeFromNib() {
        super.awakeFromNib()
        // adds border
        style()
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
        roundCorners(layer: container.layer)
        addShadow(to: container.layer, opacity:defaultContainerShadowOpacity(), height: defaultContainershadowHeight())
        styleSubHeader(label: header)
        styleSubHeader(label: nameLabel)
        styleTextviewInputField(field: descriptionTextView, header: nameLabel)

    }
}
