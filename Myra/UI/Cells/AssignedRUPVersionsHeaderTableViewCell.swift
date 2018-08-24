//
//  AssignedRUPVersionsHeaderTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPVersionsHeaderTableViewCell: UITableViewCell, Theme {
    static let cellHeight = 40

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var submitted: UILabel!
    @IBOutlet weak var effectiveDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func style() {
        styleFieldHeader(label: status)
        styleFieldHeader(label: type)
        styleFieldHeader(label: submitted)
        styleFieldHeader(label: effectiveDate)
    }
    
}
