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

    // Sort headers
    func defaultSortHeaderOnColor() -> UIColor {
        return Colors.secondary
    }

    func defaultSortHeaderOffColor() -> UIColor {
        return Colors.primary
    }

    // Shadow
    func defaultShadowColor() -> CGColor {
        return Colors.shadowColor
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
        return Fonts.getPrimaryBold(size: 14)
    }

    // Section Header
    func defaultSectionHeaderColor() -> UIColor {
        return Colors.primary
    }

    func defaultSectionHeaderFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 34)
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

    func defaultBodyTextColor() -> UIColor {
        return Colors.technical.mainText
    }

    func defaultBodyFont() -> UIFont {
        return Fonts.getPrimary(size: 15)
    }

    func defaultSectionSubHeaderFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }

    // Nav Bar
    func defaultNavBarTitleFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }

    func defaultNavBarButtonFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
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

    // MARK: Buttons
    func styleHollowButton(button: UIButton) {
        styleButton(button: button, bg: defaultHollowButtonBackground(), borderColor: defaultHollowButtonBorderColor(), titleColor: defaultHollowButtonTitleColor())
    }

    func styleFillButton(button: UIButton) {
        styleButton(button: button, bg: defaultFillButtonBackground(), borderColor: defaultFillButtonBorderColor(), titleColor: defaultFillButtonTitleColor())
        if let label = button.titleLabel {
            label.font = Fonts.getPrimary(size: 17)
        }
    }

    func styleButton(button: UIButton, bg: UIColor, borderColor: CGColor, titleColor: UIColor) {
        button.layer.cornerRadius = 5
        button.backgroundColor = bg
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor
        button.setTitleColor(titleColor, for: .normal)
    }
    
    func styleCustomButtonHollow(container: UIView, label: UILabel) {
        container.backgroundColor = defaultHollowButtonBackground()
        label.textColor = defaultHollowButtonTitleColor()
        label.font = Fonts.getPrimary(size: 17)
        
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 1
        container.layer.borderColor = defaultHollowButtonBorderColor()
    }
    
    func styleCustomButtonFill(container: UIView, label: UILabel) {
        container.backgroundColor = defaultFillButtonBackground()
        label.textColor = defaultFillButtonTitleColor()
        label.font = Fonts.getPrimary(size: 17)
        
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 1
        container.layer.borderColor = defaultFillButtonBorderColor()
    }

    // MARK: Containers and dividers
    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }

    func makeCircle(button: UIButton) {
        makeCircle(layer: button.layer, height: button.bounds.height)
    }

    func makeCircle(layer: CALayer, height: CGFloat) {
        layer.cornerRadius = height/2
    }

    func styleContainer(view: UIView) {
        roundCorners(layer: view.layer)
        addShadow(to: view.layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight())
    }

    func styleContainer(layer: CALayer) {
        layer.masksToBounds = true
        roundCorners(layer: layer)
        addShadow(to: layer, opacity: defaultContainerShadowOpacity(), height: defaultContainershadowHeight())
    }

    func styleDivider(divider: UIView) {
        divider.backgroundColor = defaultDividerColor()
    }
    
    func styleGreyDivider(divider: UIView) {
        divider.backgroundColor = UIColor(hex: "#EFEFF3")
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

    func styleFieldHeader(label: UILabel) {
        label.textColor = defaultFieldHeaderColor()
        label.font = Fonts.getPrimaryBold(size: 12)
        label.adjustsFontSizeToFitWidth = true
    }

    func styleFieldHeader(button: UIButton) {
        button.setTitleColor(defaultFieldHeaderColor(), for: .normal)
        button.titleLabel?.font = Fonts.getPrimaryBold(size: 12)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    func styleSortHeaderOff(button: UIButton) {
        button.setTitleColor(defaultSortHeaderOffColor(), for: .normal)
        button.titleLabel?.font = Fonts.getPrimaryBold(size: 12)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setImage(#imageLiteral(resourceName: "icon_arrow_highlightOff"), for: .normal)
        // set button image on the right
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: (0.0 - (button.imageView?.frame.size.width)!), bottom: 0, right: (button.imageView?.frame.size.width)!);
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (button.titleLabel?.frame.size.width)!, bottom: 0, right: (0.0 - (button.titleLabel?.frame.size.width)!))
    }

    func styleSortHeaderOn(button: UIButton) {
        button.setTitleColor(defaultSortHeaderOnColor(), for: .normal)
        button.titleLabel?.font = Fonts.getPrimaryBold(size: 12)
        button.setImage(#imageLiteral(resourceName: "icon_arrow_highlight"), for: .normal)
        // set button image on the right
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: (0.0 - (button.imageView?.frame.size.width)!), bottom: 0, right: (button.imageView?.frame.size.width)!);
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (button.titleLabel?.frame.size.width)!, bottom: 0, right: (0.0 - (button.titleLabel?.frame.size.width)!))
    }

    func styleSubHeader(label: UILabel) {
        label.textColor = defaultSectionSubHeaderColor()
        label.font = defaultSectionSubHeaderFont()
        label.change(kernValue: -0.52)
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFlowTitle(label: UILabel) {
        label.font = Fonts.getPrimaryBold(size: 22)
        label.textColor = Colors.active.blue
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFlowSubTitle(label: UILabel) {
        label.font = Fonts.getPrimary(size: 17)
        label.textColor = UIColor.black
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFlowReview(textView: UITextView) {
        textView.font = Fonts.getPrimary(size: 17)
        textView.textColor = UIColor.black
    }
    
    func styleFlowOptionName(label: UILabel) {
        label.textColor = defaultFieldHeaderColor()
        label.font = Fonts.getPrimaryBold(size: 14)
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFlowOptionDescription(label: UILabel) {
        label.textColor = defaultFieldHeaderColor()
        label.font = Fonts.getPrimary(size: 14)
        label.adjustsFontSizeToFitWidth = true
    }

    func styleBody(label: UILabel) {
        label.textColor = defaultBodyTextColor()
        label.font = defaultBodyFont()
        label.change(kernValue: -0.52)
        label.adjustsFontSizeToFitWidth = true
    }

    func styleHeader(label: UILabel, divider: UIView? = nil) {
        if let divider = divider {
            styleDivider(divider: divider)
        }
        label.textColor = defaultSectionHeaderColor()
        label.font = defaultSectionHeaderFont()
        label.change(kernValue: -0.42)
        label.adjustsFontSizeToFitWidth = true
    }

    func styleFooter(label: UILabel) {
        label.textColor = defaultSectionFooterColor()
        label.font = defaultSectionFooterFont()
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFooter(textView: UITextView) {
        textView.textColor = defaultSectionFooterColor()
        textView.font = defaultSectionFooterFont()
    }

    // MARK: Input fields
    func styleInputField(field: UITextField, header: UILabel, height: NSLayoutConstraint) {
        styleInputField(field:field, editable: true, height: height)
        styleFieldHeader(label: header)
    }

    func styleInputFieldReadOnly(field: UITextField, header: UILabel, height: NSLayoutConstraint) {
        styleInputField(field:field, editable: false, height: height)
        styleFieldHeader(label: header)
    }

    func styleInput(input: UITextField, height: NSLayoutConstraint) {
        input.textColor = defaultInputFieldTextColor()
        input.backgroundColor = defaultInputFieldBackground()
        input.font = defaultInputFieldFont()
        input.layer.cornerRadius = 3
        input.borderStyle = .roundedRect
        input.layer.borderColor = defaultInputFieldBackground().cgColor
        height.constant = defaultInputFieldHeight()
    }

    func styleInputReadOnly(input: UITextField, height: NSLayoutConstraint) {
        input.borderStyle = .none
        input.isUserInteractionEnabled = false
        input.textColor = defaultInputFieldTextColor()
        input.backgroundColor = UIColor.clear
        input.font = defaultInputFieldFont()
        input.layer.cornerRadius = 3
        input.borderStyle = .roundedRect
        input.layer.borderColor = UIColor.clear.cgColor
        height.constant = defaultInputFieldHeight()
    }

    func styleInputField(field: UITextField, editable: Bool, height: NSLayoutConstraint) {
        styleInput(input: field, height: height)
        if editable {
            field.isUserInteractionEnabled = true
            field.backgroundColor = defaultInputFieldBackground()
        } else {
            field.borderStyle = .none
            field.backgroundColor = UIColor.clear
            field.isUserInteractionEnabled = false
        }
    }

    func styleTextviewInputField(field: UITextView, header: UILabel? = nil) {
        field.isEditable = true
        field.textColor = defaultInputFieldTextColor()
        field.backgroundColor = defaultInputFieldBackground()
        field.font = defaultInputFieldFont()
        field.layer.cornerRadius = 3
        if header != nil {
            styleFieldHeader(label: header!)
        }
    }

    func styleTextviewInputFieldReadOnly(field: UITextView, header: UILabel) {
        field.isEditable = false
        field.textColor = defaultInputFieldTextColor()
        field.backgroundColor = UIColor.clear
        field.font = defaultInputFieldFont()
        field.layer.cornerRadius = 3
        field.layer.borderColor = Colors.shadowColor
        field.layer.borderWidth = 1
        styleFieldHeader(label: header)
    }

    // MARK: Filter
    func styleFilter(label: UILabel) {
        label.font = Fonts.getPrimaryMedium(size: 17)
        label.change(kernValue: -0.41)
        label.adjustsFontSizeToFitWidth = true
    }

    // MARK: Table
    func styleTableColumnHeader(label: UILabel) {
        label.font = Fonts.getPrimaryMedium(size: 17)
        label.textColor = Colors.technical.mainText
        label.change(kernValue: -0.41)
        label.adjustsFontSizeToFitWidth = true
    }

    // MARK: Radio
    func styleRadioOff(view: UIView, imageView: UIImageView) {
        makeCircle(view: view)
        view.layer.backgroundColor = defaultInputFieldBackground().cgColor
        imageView.alpha = 0
    }

    func styleRadioOn(view: UIView, imageView: UIImageView) {
        makeCircle(view: view)
        view.layer.backgroundColor = UIColor.white.cgColor
        imageView.alpha = 1
        imageView.image = #imageLiteral(resourceName: "icon_check")
    }

    // MARK: Shadows
    func addShadow(layer: CALayer) {
        addShadow(to: layer, opacity: 1, height: 2)
    }

    func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = defaultShadowColor()
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = defaultShadowColor()
        layer.shadowOpacity = opacity
        var r: CGFloat = 10
        if let radius = radius {
            r = radius
        }
        layer.shadowRadius = r
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
        label.adjustsFontSizeToFitWidth = true
    }

    func StyleNavBarButton(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = defaultNavBarButtonFont()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    func styleStatusBar(view: UIView) {
        view.backgroundColor = Colors.primary
    }

    func styleNavBarLabel(label: UILabel) {
        label.textColor = UIColor.white
        label.font = defaultNavBarLabelFont()
        label.adjustsFontSizeToFitWidth = true
    }

    func menuSectionOff(label: UILabel) {
        label.textColor = Colors.technical.mainText
        label.font = Fonts.getPrimaryMedium(size: 15)
        label.adjustsFontSizeToFitWidth = true
    }

    func menuSectionOn(label: UILabel) {
        label.textColor = Colors.primary
        label.font = Fonts.getPrimaryMedium(size: 15)
        label.adjustsFontSizeToFitWidth = true
    }

}

extension Theme {
    // Tooltip

    func toolTipDescriptionFont() -> UIFont {
        return Fonts.getPrimary(size: 14)
    }
    func styleToolTipDescription(textView: UITextView) {
        textView.font = toolTipDescriptionFont()
        textView.textColor = UIColor.white
        textView.backgroundColor = Colors.active.blue
    }

    func toolTipTitleFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }

    func styleToolTipTitle(label: UILabel) {
        label.font = toolTipTitleFont()
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
    }
}

