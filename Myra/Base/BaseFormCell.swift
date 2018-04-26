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

    // Input Field
    let defaultInputFieldHeight: CGFloat = 45
    let defaultInputFieldBackground = Colors.inputBG
    let defaultInputFieldTextColor = Colors.inputText
    let defaultInputFieldFont = Fonts.getPrimary(size: 15)

    // Field Header
    let defaultFieldHeaderColor = Colors.inputHeaderText
    let defaultFieldHeaderFont = Fonts.getPrimaryHeavy(size: 14)

    // Section Header
    let defaultSectionHeaderColor = Colors.primary
    let defaultSectionHeaderFont = Fonts.getPrimaryHeavy(size: 34)

    // Section Sub Header
    let defaultSectionSubHeaderColor = Colors.primary
    let defaultSectionSubHeaderFont = Fonts.getPrimaryHeavy(size: 17)

    // MARK: Variables
    var rup: RUP = RUP()
    var mode: FormMode = .Create

    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Cell Setup
    func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
    }

    // MARK: Styles
    func styleInput(input: UITextField) {
        input.layer.cornerRadius = 3
        input.layer.backgroundColor = Colors.inputBG.cgColor
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
        layer.borderColor = Colors.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = Colors.shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 3
    }

    func styleContainer(view: UIView) {
        roundCorners(layer: view.layer)
        addShadow(to: view.layer, opacity: defaultContainerShadowOpacity, height: defaultContainershadowHeight)
    }

    func styleContainer(layer: CALayer) {
        roundCorners(layer: layer)
        addShadow(to: layer, opacity: defaultContainerShadowOpacity, height: defaultContainershadowHeight)
    }

    func addBoarder(layer: CALayer, cornerRadius: CGFloat) {
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.black.cgColor
    }

    func styleStaticField(field: UILabel, header: UILabel) {
        styleStaticField(field: field)
        styleFieldHeader(label: header)
    }

    func styleStaticField(field: UILabel) {
        field.textColor = defaultInputFieldTextColor
        field.font = defaultInputFieldFont
    }

    func styleInputField(field: UITextField, header: UILabel, height: NSLayoutConstraint) {
        height.constant = defaultInputFieldHeight
        styleInputField(field:field, editable: true)
        styleFieldHeader(label: header)
    }

    func styleInputField(field: UITextField, editable: Bool) {
        field.textColor = defaultInputFieldTextColor
        field.font = defaultInputFieldFont
        field.layer.cornerRadius = 3
        if editable {
             field.backgroundColor = defaultInputFieldBackground
        } else {
            field.backgroundColor = UIColor.clear
            field.isUserInteractionEnabled = false
        }
    }

    func styleInputField(field: UITextView, header: UILabel) {
        field.textColor = defaultInputFieldTextColor
        field.backgroundColor = defaultInputFieldBackground
        field.font = defaultInputFieldFont
        field.layer.cornerRadius = 3
        styleFieldHeader(label: header)
    }

    func styleFieldHeader(label: UILabel) {
        label.textColor = defaultFieldHeaderColor
        label.font = defaultFieldHeaderFont
    }

    func styleSubHeader(label: UILabel) {
        label.textColor = defaultSectionSubHeaderColor
        label.font = defaultSectionSubHeaderFont
    }

    func styleHeader(label: UILabel, divider: UIView) {
        styleDivider(divider: divider)
        label.textColor = defaultSectionHeaderColor
        label.font = defaultSectionHeaderFont
    }

    func styleDivider(divider: UIView) {
        divider.backgroundColor = Colors.secondary
    }
}
