//
//  AssignedRUPTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AssignedRUPTableViewCell: UITableViewCell {

    // MARK: Variables
    var rup: RUP?

    // MARK: Outlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var ammendButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        if rup != nil { setupView(rup: rup!)}
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Outlet Actions
    @IBAction func viewAction(_ sender: Any) {
        if rup == nil {return}
        let parent = self.parentViewController as! HomeViewController
        parent.viewRUP(rup: rup!)
    }

    @IBAction func ammendAction(_ sender: Any) {
        if rup == nil {return}
        let parent = self.parentViewController as! HomeViewController
        parent.amendRUP(rup: rup!)
    }

    // MARK: Functions
    func set(rup: RUP) {
        self.rup = rup
        setupView(rup: rup)
    }

    func setupView(rup: RUP) {
        self.idLabel.text = rup.id
        self.infoLabel.text = rup.info
    }
}
