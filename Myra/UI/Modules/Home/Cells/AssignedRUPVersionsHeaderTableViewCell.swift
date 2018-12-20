//
//  AssignedRUPVersionsHeaderTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-16.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPVersionsHeaderTableViewCell: BaseTableViewCell {

    // MARK: Variables
    static let cellHeight = 40

    // MARK: Outlets
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var submitted: UILabel!
    @IBOutlet weak var effectiveDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Styles
    func style() {
        styleFieldHeader(label: status)
        styleFieldHeader(label: type)
        styleFieldHeader(label: submitted)
        styleFieldHeader(label: effectiveDate)
    }
    
}
