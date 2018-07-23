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

    // MARK: Constants
    static let cellHeight = 60

    // MARK: Variables
    var plantCommunity: PlantCommunity?
    var parentCellReference: PastureTableViewCell?
    var pasture: Pasture?

    // MARK: ViewController functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // adds border
        style()
    }

    // MARK: Outlet Actions
    @IBAction func detailsAction(_ sender: UIButton) {
        guard let community = self.plantCommunity, let p = self.pasture, let parentCell = self.parentCellReference else {return}
        let grandParent = self.parentViewController as! CreateNewRUPViewController
        grandParent.showPlantCommunity(pasture: p, plantCommunity: community) { (done) in
            print("validate here")
            parentCell.updateTableHeight()
        }
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity, let parent = parentCellReference else {return}

        let grandParent = self.parentViewController as! CreateNewRUPViewController

        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Delete, display: "Delete")]

        optionsVC.setup(options: options) { (option) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch option.type {
            case .Delete:
                grandParent.showAlert(title: "Would you like to delete this Plant Community?", description: "All monioring areas and pasture actions will also be removed", yesButtonTapped: {
                    RealmManager.shared.deletePlantCommunity(object: pc)
                    parent.updateTableHeight()
                }, noButtonTapped: {})

            case .Copy:
                print("not yet implemented")
//                self.duplicate()
            }
        }

        grandParent.showPopOver(on: sender , vc: optionsVC, height: optionsVC.suggestedHeight, width: optionsVC.suggestedWidth, arrowColor: nil)

    }

    // MARK: Setup
    func setup(mode: FormMode, plantCommunity: PlantCommunity, pasture: Pasture, parentCellReference: PastureTableViewCell) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.pasture = pasture
        self.parentCellReference = parentCellReference
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
    }
}
