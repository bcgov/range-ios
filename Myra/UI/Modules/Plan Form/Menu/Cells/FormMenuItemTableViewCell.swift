//
//  FormMenuItemTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-04.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FormMenuItemTableViewCell: UITableViewCell {
    
    var section: FromSection?
    var callBack: (()-> Void)?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var sideBar: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var iconLeading: NSLayoutConstraint!
    @IBOutlet weak var labelLeading: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func clickAction(_ sender: Any) {
        if let clicked = self.callBack {
            return clicked()
        }
        
    }
    
    func setup(forSection section: FromSection, isOn: Bool, isExpanded: Bool, clicked: @escaping()-> Void) {
        self.section = section
        self.callBack = clicked
        styleSection(isOn: isOn, isExpanded: isExpanded)
    }
    
    func styleSection(isOn: Bool, isExpanded: Bool) {
        guard let section = self.section else {return}
        style()
        
        var iconExtension = ""
        
        if !isOn {
            iconExtension = "_off"
            label.textColor = Colors.technical.mainText
            sideBar.backgroundColor = UIColor.clear
        } else {
            label.textColor = Colors.primary
            sideBar.backgroundColor =  Colors.secondary
        }
        
        switch section {
        case .BasicInfo:
            self.label.text = "Basic Information"
            self.icon.image = UIImage(named: "icon_basicInformation\(iconExtension)")
        case .Pastures:
            self.label.text = "Pastures"
            self.icon.image = UIImage(named: "icon_Pastures\(iconExtension)")
        case .YearlySchedule:
            self.label.text = "Yearly Schedule"
            self.icon.image = UIImage(named: "icon_Schedule\(iconExtension)")
        case .MinistersIssues:
            self.label.text = "Minister's Issues"
            self.icon.image = UIImage(named: "icon_MinistersIssues\(iconExtension)")
        case .InvasivePlants:
            self.label.text = "Invasive Plants"
            self.icon.image = UIImage(named: "icon_invasivePlants\(iconExtension)")
        case .AdditionalRequirements:
            self.label.text = "Additional Requirements"
            self.icon.image = UIImage(named: "icon_additionalReqs\(iconExtension)")
        case .ManagementConsiderations:
            self.label.text = "Management Considerations"
            self.icon.image = UIImage(named: "icon_Management\(iconExtension)")
        case .Map:
            self.label.text = "Map"
            self.icon.image = UIImage(named: "icon_Map\(iconExtension)")
        }
        
        if canDisplayFullText() {
            self.label.alpha = 1
        } else {
            self.label.alpha = 0
        }
//        if isExpanded {
//            self.iconLeading.constant = 10
//            self.label.alpha = 1
//        } else {
//            let portraitMenuWidth: CGFloat = 6
//            let leftBar: CGFloat = 12
////            self.iconLeading.constant = ((portraitMenuWidth - icon.frame.width - leftBar) / 2)
//            self.label.alpha = 0
//        }
    }
    
    func canDisplayFullText() -> Bool {
        guard let currenLabel = self.label.text else { return false}
        let minWidth = self.sideBar.frame.width + self.icon.frame.width + self.iconLeading.constant
        let textWidth = currenLabel.width(withConstrainedHeight: self.frame.height, font: label.font)
        let widthNeeded = minWidth + textWidth + self.labelLeading.constant
        return (widthNeeded <= self.frame.width)
    }
    
    func style() {
        label.font = Fonts.getPrimaryMedium(size: 15)
        self.container.backgroundColor = UIColor.clear
        self.bottomSeparator.alpha = 0.1
    }
}
