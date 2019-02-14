//
//  PlantCommunityTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityTableViewCell: BaseFormCell {

    // MARK: Variables
    static let cellHeight = 60
    var plantCommunity: PlantCommunity?
    var parentCellReference: PastureTableViewCell?
    var pasture: Pasture?

    // MARK: Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!

    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Outlet Actions
    @IBAction func detailsAction(_ sender: UIButton) {
        guard let plantCommunity = self.plantCommunity, let pasture = self.pasture, let plan = self.plan, let presenter = self.getPresenter() else {return}
        presenter.showPlanCommunityDetails(for: plantCommunity, of: pasture, in: plan, mode: self.mode)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let pc = self.plantCommunity, let parent = parentCellReference else {return}

        let grandParent = self.parentViewController as! CreateNewRUPViewController

        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Delete, display: "Delete")]

        optionsVC.setup(options: options, onVC: grandParent, onButton: sender) { (option) in
            optionsVC.dismiss(animated: true, completion: nil)
            switch option.type {
            case .Delete:
                grandParent.showAlert(title: "Would you like to delete this Plant Community?", description: "All monioring areas and pasture actions will also be removed", yesButtonTapped: {
                    RealmManager.shared.deletePlantCommunity(object: pc)
                    parent.updateTableHeight()
                }, noButtonTapped: {})

            case .Copy:
                Logger.log(message: "Not Yet Implemeneted")
            }
        }
    }
    
    // MAKR: Notifications
    func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(planChanged), name: .planChanged, object: nil)
    }
    
    @objc func planChanged(_ notification:Notification) {
        styleBasedOnValidity()
    }

    // MARK: Setup
    func setup(mode: FormMode, plantCommunity: PlantCommunity, pasture: Pasture, plan: Plan, parentCellReference: PastureTableViewCell) {
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.pasture = pasture
        self.plan = plan
        self.parentCellReference = parentCellReference
        autofill()
        style()
        setupListeners()
    }

    func autofill() {
        guard let pc = self.plantCommunity else {return}
        self.nameLabel.text = pc.name
    }
    
    // MARK: Styles
    func style() {
        roundCorners(layer: container.layer)
        addShadow(to: container.layer, opacity:defaultContainerShadowOpacity(), height: defaultContainershadowHeight(), radius: 5)
        styleSubHeader(label: header)
        styleSubHeader(label: nameLabel)
        switch mode {
        case .View:
            optionsButton.alpha = 0
        case .Edit:
            optionsButton.alpha = 1
        }
        styleBasedOnValidity()
    }
    
    func styleBasedOnValidity() {
        refreshPlantCommunityObject()
        guard let pc = self.plantCommunity else {return}
        
        for ma in pc.monitoringAreas {
            if !ma.requiredFieldsAreFilled() {
                styleInvalid()
                return
            }
        }
        
        if pc.requiredFieldsAreFilled() {
            styleValid()
        } else {
            styleInvalid()
        }
    }
    
    func styleValid() {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.header.textColor = Colors.invalid
            self.nameLabel.textColor = Colors.invalid
            self.layoutIfNeeded()
        })
    }
    
    func styleInvalid() {
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            self.styleSubHeader(label: self.header)
            self.styleSubHeader(label: self.nameLabel)
            self.layoutIfNeeded()
        })
    }
    
    func refreshPlantCommunityObject() {
        guard let pc = self.plantCommunity else {return}
        do {
            let realm = try Realm()
            let aPC = realm.objects(PlantCommunity.self).filter("localId = %@", pc.localId).first!
            self.plantCommunity = aPC
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }
}
