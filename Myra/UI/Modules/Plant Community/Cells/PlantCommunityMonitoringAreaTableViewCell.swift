//
//  PlantCommunityMonitoringAreaTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityMonitoringAreaTableViewCell: BaseTableViewCell {

    // Mark: Constants
    static let cellHeight = 72.0

    // MARK: Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var name: UILabel!

    // MARK: Variables
    var monitoringArea: MonitoringArea?
    var mode: FormMode = .View
    var parentReference: PlantCommunityViewController?
    var parentCellReference: PlantCommunityMonitoringAreasTableViewCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        autofill()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet actions
    @IBAction func cellClickAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let parent = self.parentReference else {return}
        parent.showMonitoringAreaDetailsPage(monitoringArea: ma)
    }

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let ma = self.monitoringArea, let parent = parentReference, let parentCell = parentCellReference else {return}

        let vm = ViewManager()
        let optionsVC = vm.options

        let options: [Option] = [Option(type: .Delete, display: "Delete")]

        optionsVC.setup(options: options, onVC: parent, onButton: sender) { (option) in
            switch option.type {
            case .Delete:
                parent.showAlert(title: "Would you like to delete this Plant Community?", description: "All monioring areas and pasture actions will also be removed", yesButtonTapped: {
                    RealmManager.shared.deleteMonitoringArea(object: ma)
                    parentCell.updateTableHeight()
                }, noButtonTapped: {})

            case .Copy:
                Logger.log(message: "Not Yet Implemeneted")
            }
        }
    }

    // MARK: Setup
    func setup(monitoringArea: MonitoringArea, mode: FormMode, parentCellReference: PlantCommunityMonitoringAreasTableViewCell, parentReference: PlantCommunityViewController) {
        self.monitoringArea = monitoringArea
        self.mode = mode
        self.parentReference = parentReference
        self.parentCellReference = parentCellReference
        autofill()
        style()
    }

    func autofill() {
        guard let area = self.monitoringArea, let _ = name else {return}
        self.name.text = area.name
    }

    func style() {
        styleContainer(view: container)
    }
    
}
