//
//  ImportCriteriaOptionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ImportCriteriaOptionTableViewCell: UITableViewCell {

    var parent: ChoosePastureCollectionViewCell?
    var option: String = ""

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func CellTapped(_ sender: Any) {
        sendBack()
    }

    func set(name: String, parent: ChoosePastureCollectionViewCell, selected: Bool) {
        self.option = name
        self.parent = parent
        autofill(selected: selected)
    }

    func autofill(selected: Bool) {
        self.label.text = option
        if selected {
            self.checkIcon.image = UIImage(named: "icon_check")
            self.label.textColor = Colors.active.blue
        } else {
            self.checkIcon.image = nil
            self.label.textColor = UIColor.black
        }
    }

    func sendBack() {
        guard let parent = self.parent else {return}
        parent.selectOption(named: option)
    }

    func style() {
        self.label.font = Fonts.getPrimary(size: 17)
    }
}
