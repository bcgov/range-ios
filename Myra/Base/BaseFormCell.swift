//
//  BaseFormCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-01.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseFormCell: UITableViewCell {

    // MARK: Constants
    let defaultContainerShadowOpacity: Float = 0.4
    let defaultContainershadowHeight = 2

    let defaultInputFieldHeight: CGFloat = 45
    let defaultInputFieldBackground = Colors.inputBG
    let defaultInputFieldTextColor = Colors.inputText
    let defaultInputFieldFont = Fonts.getPrimary(size: 15)

    let defaultFieldHeaderColor = Colors.inputHeaderText
    let defaultFieldHeaderFont = Fonts.getPrimary(size: 14)

    let defaultSectionHeaderColor = Colors.primary
    let defaultSectionHeaderFont = Fonts.getPrimaryHeavy(size: 34)

    let defaultSectionSubHeaderColor = Colors.primary
    let defaultSectionSubHeaderFont = Fonts.getPrimaryHeavy(size: 17)

    // MARK: Variables
    var rup: RUP = RUP()
    var mode: FormMode = .Create

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
    }

    func styleInput(input: UITextField) {
        input.layer.cornerRadius = 3
        input.layer.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1).cgColor
    }

    func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.primary.cgColor
        button.setTitleColor(Colors.primary, for: .normal)
    }

    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }

    func addShadow(to layer: CALayer, opacity: Float, height: Int) {
        layer.borderColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 3
    }

    func styleContainer(view: UIView) {
        roundCorners(layer: view.layer)
        addShadow(to: view.layer, opacity: defaultContainerShadowOpacity, height: defaultContainershadowHeight)
    }

    func addBoarder(layer: CALayer, cornerRadius: CGFloat) {
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.black.cgColor
    }

    func styleInputField(field: UITextField, header: UILabel, height: NSLayoutConstraint) {
        height.constant = defaultInputFieldHeight
        field.textColor = defaultInputFieldTextColor
        field.backgroundColor = defaultInputFieldBackground
        field.font = defaultInputFieldFont
        field.layer.cornerRadius = 3
        header.textColor = defaultFieldHeaderColor
        header.font = defaultFieldHeaderFont
    }

    func styleInputField(field: UITextView, header: UILabel) {
        field.textColor = defaultInputFieldTextColor
        field.backgroundColor = defaultInputFieldBackground
        field.font = defaultInputFieldFont
        field.layer.cornerRadius = 3
        header.textColor = defaultFieldHeaderColor
        header.font = defaultFieldHeaderFont
    }

    func styleSubHeader(label: UILabel) {
        label.textColor = defaultSectionSubHeaderColor
        label.font = defaultSectionSubHeaderFont
    }

    func styleHeader(label: UILabel, divider: UIView) {
        divider.backgroundColor = Colors.secondary
        label.textColor = defaultSectionHeaderColor
        label.font = defaultSectionHeaderFont
    }
}
