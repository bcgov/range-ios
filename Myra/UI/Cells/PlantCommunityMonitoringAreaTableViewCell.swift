//
//  PlantCommunityMonitoringAreaTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityMonitoringAreaTableViewCell: UITableViewCell, Theme {

    // Mark: Constants
    static let cellHeight = 72.0

    // MARK: Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var name: UILabel!

    // MARK: Variables
    var monitoringArea: MonitoringArea?
    var mode: FormMode = .View

    override func awakeFromNib() {
        super.awakeFromNib()
        autofill()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet actions
    @IBAction func cellClickAction(_ sender: UIButton) {
        
    }

    // MARK: Setup
    func setup(monitoringArea: MonitoringArea, mode: FormMode) {
        self.monitoringArea = monitoringArea
        self.mode = mode
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
