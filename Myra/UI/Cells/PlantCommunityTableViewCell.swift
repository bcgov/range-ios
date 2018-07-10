//
//  PlantCommunityTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityTableViewCell: BaseFormCell {

    // MARK: Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: Variables
    var plantCommunity: PlantCommunity?
    var pasture: Pasture?

    // MARK: ViewController functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // adds border
        style()
    }

    // MARK: Outlet Actions
    @IBAction func detailsAction(_ sender: UIButton) {
        guard let community = self.plantCommunity, let p = self.pasture else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        grandParent.showPlantCommunity(pasture: p, plantCommunity: community) { (done) in
            print("validate here")
        }
    }

    // MARK: Setup
    func setup(mode: FormMode, plantCommunity: PlantCommunity, pasture: Pasture) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.pasture = pasture
//        setupNotifications()
//        notifyReload()
        autofill()
    }

    func autofill() {
        guard let pc = self.plantCommunity else {return}
        self.nameLabel.text = pc.name
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
