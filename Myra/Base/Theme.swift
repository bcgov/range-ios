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
    func defaultContainerShadowOpacity() -> Float {
        return 0.4
    }
    func defaultContainershadowHeight() -> Int {
        return 2
    }

    // Input Field
    func defaultInputFieldHeight() ->  CGFloat{
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

    // MARK: Styles

    // MARK: Buttons
    func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.primary.cgColor
        button.setTitleColor(Colors.primary, for: .normal)
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
        divider.backgroundColor = Colors.secondary
    }

    func addBoarder(layer: CALayer, cornerRadius: CGFloat) {
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.black.cgColor
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
        height.constant = defaultInputFieldHeight()
        styleInputField(field:field, editable: true)
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

    func styleHeader(label: UILabel, divider: UIView) {
        styleDivider(divider: divider)
        label.textColor = defaultSectionHeaderColor()
        label.font = defaultSectionHeaderFont()
    }

    // MARK: Input fields
    func styleInput(input: UITextField) {
        input.layer.cornerRadius = 3
        input.layer.backgroundColor = Colors.inputBG.cgColor
    }

    func styleInputField(field: UITextField, editable: Bool) {
        field.textColor = defaultInputFieldTextColor()
        field.font = defaultInputFieldFont()
        field.layer.cornerRadius = 3
        if editable {
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
        layer.borderColor = Colors.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = Colors.shadowColor.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
    }

    func addShadow(to layer: CALayer, opacity: Float, height: Int) {
        layer.borderColor = Colors.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = Colors.shadowColor.cgColor
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

}
