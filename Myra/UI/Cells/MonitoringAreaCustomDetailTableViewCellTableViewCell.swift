//
//  MonitoringAreaCustomDetailTableViewCellTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-17.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class MonitoringAreaCustomDetailTableViewCellTableViewCell: UITableViewCell {

    // Mark: Constants
    static let cellHeight = 66

    // MARK: Variables
    var mode: FormMode = .View
    var area: MonitoringArea?
    var parentReference: MonitoringAreaViewController?
    var indicatorPlant: IndicatorPlant?

    // MARK: Outlets
    @IBOutlet weak var rightField: UITextField!
    @IBOutlet weak var leftField: UITextField!
    @IBOutlet weak var rightFIeldButton: UIButton!
    @IBOutlet weak var leftFieldButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func leftFieldAction(_ sender: UIButton) {
    }

    @IBAction func rightFieldAction(_ sender: UIButton) {
    }

    @IBAction func rightFieldValueChanged(_ sender: UITextField) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func optionsAction(_ sender: UIButton) {
    }
    
    func setup(mode: FormMode, indicatorPlant: IndicatorPlant, area: MonitoringArea, parentReference: MonitoringAreaViewController) {
        self.mode = mode
        self.area = area
        self.parentReference = parentReference
        self.indicatorPlant = indicatorPlant
        
    }
    
}
