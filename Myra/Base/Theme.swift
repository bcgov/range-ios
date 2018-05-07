//
//  Theme.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

protocol Theme {}
extension Theme {

    // MARK: Constants

    // Shadow
    func defaultShadowColor() -> CGColor {
        return Colors.shadowColor.cgColor
    }
    func defaultContainerShadowOpacity() -> Float {
        return 0.4
    }
    func defaultContainershadowHeight() -> Int {
        return 2
    }

    // Input Field
    func defaultInputFieldHeight() -> CGFloat {
        return 45
    }

    func defaultInputFieldBackground () -> UIColor {
        return Colors.inputBG
    }

    func defaultInputFieldTextColor() -> UIColor {
        return Colors.inputText
    }

    func defaultInputFieldFont() -> UIFont {
        return Fonts.getPrimary(size: 15)
    }

    // Field Header
    func defaultFieldHeaderColor() -> UIColor {
        return Colors.inputHeaderText
    }

    func defaultFieldHeaderFont() -> UIFont {
        return Fonts.getPrimaryHeavy(size: 14)
    }

    // Section Header
    func defaultSectionHeaderColor() -> UIColor {
        return Colors.primary
    }

    func defaultSectionHeaderFont() -> UIFont {
        return Fonts.getPrimaryHeavy(size: 34)
    }

    func defaultSectionFooterColor() -> UIColor {
        return Colors.bodyText
    }

    func defaultSectionFooterFont() -> UIFont {
        return Fonts.getPrimary(size: 17)
    }

    // Section Sub Header
    func defaultSectionSubHeaderColor() -> UIColor {
        return Colors.primary
    }

    func defaultSectionSubHeaderFont() -> UIFont {
        return Fonts.getPrimaryHeavy(size: 17)
    }

    // Nav Bar
    func defaultNavBarTitleFont() -> UIFont {
        return Fonts.getPrimaryHeavy(size: 17)
    }

    func defaultNavBarButtonFont() -> UIFont {
        return Fonts.getPrimaryHeavy(size: 17)
    }

    func defaultNavBarLabelFont() -> UIFont {
        return Fonts.getPrimaryMedium(size: 14)
    }

    // Button
    func defaultHollowButtonBorderColor() -> CGColor {
        return Colors.primary.cgColor
    }

    func defaultHollowButtonBackground() -> UIColor {
        return UIColor.white
    }

    func defaultHollowButtonTitleColor() -> UIColor {
        return Colors.primary
    }

    func defaultFillButtonBorderColor() -> CGColor {
        return Colors.primary.cgColor
    }

    func defaultFillButtonBackground() -> UIColor {
        return Colors.primary
    }

    func defaultFillButtonTitleColor() -> UIColor {
        return UIColor.white
    }

    // Border
    func defaultBorderColor() -> UIColor {
        return Colors.secondary
    }

    func defaultDividerColor() -> UIColor {
        return Colors.secondary
    }

    // MARK: Styles

    // MARK: Buttons
    func styleHollowButton(button: UIButton) {
        styleButton(button: button, bg: defaultHollowButtonBackground(), borderColor: defaultHollowButtonBorderColor(), titleColor: defaultHollowButtonTitleColor())
    }

    func styleFillButton(button: UIButton) {
        styleButton(button: button, bg: defaultFillButtonBackground(), borderColor: defaultFillButtonBorderColor(), titleColor: defaultFillButtonTitleColor())
    }

    func styleButton(button: UIButton, bg: UIColor, borderColor: CGColor, titleColor: UIColor) {
        button.layer.cornerRadius = 5
        button.backgroundColor = bg
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor
        button.setTitleColor(titleColor, for: .normal)
    }

    // MARK: Containers and dividers
    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }

    func styleContainer(view: UIView) {
        roundCorners(layer: view.layer)
        addShadow(to: view.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight())
    }

    func styleContainer(layer: CALayer) {
        roundCorners(layer: layer)
        addShadow(to: layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight())
    }

    func styleDivider(divider: UIView) {
        divider.backgroundColor = defaultDividerColor()
    }

    func addBoarder(layer: CALayer, cornerRadius: CGFloat) {
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius
        layer.borderColor = defaultBorderColor().cgColor
    }

    // MARK: Static fields
    func styleStaticField(field: UILabel, header: UILabel) {
        styleStaticField(field: field)
        styleFieldHeader(label: header)
    }

    func styleStaticField(field: UILabel) {
        field.textColor = defaultInputFieldTextColor()
        field.font = defaultInputFieldFont()
    }

    func styleInputField(field: UITextField, header: UILabel, height: NSLayoutConstraint) {
        styleInputField(field:field, editable: true, height: height)
        styleFieldHeader(label: header)
    }

    func styleFieldHeader(label: UILabel) {
        label.textColor = defaultFieldHeaderColor()
        label.font = defaultFieldHeaderFont()
    }

    func styleSubHeader(label: UILabel) {
        label.textColor = defaultSectionSubHeaderColor()
        label.font = defaultSectionSubHeaderFont()
    }

    func styleHeader(label: UILabel) {
        label.textColor = defaultSectionHeaderColor()
        label.font = defaultSectionHeaderFont()
    }

    func styleHeader(label: UILabel, divider: UIView) {
        styleDivider(divider: divider)
        styleHeader(label: label)
    }

    func styleFooter(label: UILabel) {
        label.textColor = defaultSectionFooterColor()
        label.font = defaultSectionFooterFont()
    }

    // MARK: Input fields
    func styleInput(input: UITextField, height: NSLayoutConstraint) {
        input.textColor = defaultInputFieldTextColor()
        input.backgroundColor = defaultInputFieldBackground()
        input.font = defaultInputFieldFont()
        input.layer.cornerRadius = 3
        height.constant = defaultInputFieldHeight()
    }

    func styleInputField(field: UITextField, editable: Bool, height: NSLayoutConstraint) {
        styleInput(input: field, height: height)
        if editable {
            field.isUserInteractionEnabled = true
            field.backgroundColor = defaultInputFieldBackground()
        } else {
            field.backgroundColor = UIColor.clear
            field.isUserInteractionEnabled = false
        }
    }

    func styleInputField(field: UITextView, header: UILabel) {
        field.textColor = defaultInputFieldTextColor()
        field.backgroundColor = defaultInputFieldBackground()
        field.font = defaultInputFieldFont()
        field.layer.cornerRadius = 3
        styleFieldHeader(label: header)
    }

    // MARK: Shadows
    func addShadow(layer: CALayer) {
        addShadow(to: layer, opacity: 1, height: 2)
    }

    func addShadow(to layer: CALayer, opacity: Float, height: Int) {
        layer.borderColor = defaultShadowColor()
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = defaultShadowColor()
        layer.shadowOpacity = opacity
        layer.shadowRadius = 3
    }

    // MARK: NavBar
    func styleNavBar(title: UILabel, navBar: UIView, statusBar: UIView, primaryButton: UIButton, secondaryButton: UIButton?, textLabel: UILabel?) {
        navBar.backgroundColor = Colors.primary
        addShadow(to: navBar.layer, opacity: 0.8, height: 2)
        styleStatusBar(view: statusBar)
        styleNavBarTitle(label: title)
        StyleNavBarButton(button: primaryButton)

        if let secondary = secondaryButton {
            StyleNavBarButton(button: secondary)
        }

        if let text = textLabel {
            styleNavBarLabel(label: text)
        }
    }

    func styleNavBarTitle(label: UILabel) {
        label.textColor = UIColor.white
        label.font = defaultNavBarTitleFont()
    }

    func StyleNavBarButton(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = defaultNavBarButtonFont()
    }

    func styleStatusBar(view: UIView) {
        view.backgroundColor = Colors.primary
    }

    func styleNavBarLabel(label: UILabel) {
        label.textColor = UIColor.white
        label.font = defaultNavBarLabelFont()
    }

    func menuSectionOff(label: UILabel) {
        label.textColor = UIColor.black
        label.font = Fonts.getPrimary(size: 15)
    }

    func menuSectionOn(label: UILabel) {
        label.textColor = Colors.primary
        label.font = Fonts.getPrimaryMedium(size: 15)
    }

}
