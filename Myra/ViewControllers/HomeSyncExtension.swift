//
//  HomeSyncExtension.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-23.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Lottie

// Sync view
extension HomeViewController {


    // White screen's tag = 100
    // View's title = 101
    // View's description = 102
    // button's tag = 103
    // Container's tag = 104
    // animation's tag = 105
    func getSyncView() -> UIView {
        // white screen
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.9)
        view.alpha = 1

        // view that holds content
        let layerWidth: CGFloat = 400
        let layerHeight: CGFloat = 390
        let layer = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: layerWidth, height: layerHeight))
        layer.layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white
        layer.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 10
        layer.center.x = self.view.center.x
        layer.center.y = self.view.center.y
        layer.tag = 104

        // title layer
        let textLayerWidth: CGFloat = layerWidth
        let textLayerHeight: CGFloat = 26
        let textLayerTopPadding: CGFloat = 5
        let textLayer = UILabel(frame: CGRect(x: 0, y: textLayerTopPadding, width: textLayerWidth, height: textLayerHeight))
        textLayer.lineBreakMode = .byWordWrapping
        textLayer.numberOfLines = 1
        textLayer.textColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:1)
        textLayer.attributedText = getSycnTitleText(text: "Sync Changes")
        textLayer.textAlignment = .center

        textLayer.tag = 101
        // add to layer that holds content
        layer.addSubview(textLayer)

        // separator layer
        let separatorHeight: CGFloat = 1
        let separatorTopPadding: CGFloat = 5
        let separatorY: CGFloat = textLayerTopPadding + textLayerHeight
        let separator = UIView(frame: CGRect(x: 0, y: separatorY + separatorTopPadding, width: layer.frame.width, height: separatorHeight))
        separator.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        // add to layer that holds content
        layer.addSubview(separator)

        // description text
        let descWidth: CGFloat = layerWidth
        let descHeight: CGFloat = 22
         let descLayerTopPadding = separatorY + 10
        let descLayer = UILabel(frame: CGRect(x: 0, y: descLayerTopPadding, width: descWidth, height: descHeight))
        descLayer.lineBreakMode = .byWordWrapping
        descLayer.numberOfLines = 1
        descLayer.textColor = UIColor.black
        descLayer.attributedText = getSycDescriptionText(text: "WOOOOOO")
        descLayer.textAlignment = .center
//        descLayer.backgroundColor = UIColor.green

        descLayer.tag = 102
        // add to layer that holds content
        layer.addSubview(descLayer)

        // button
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 100
        let buttonButtomPadding: CGFloat = 5
        let button = UIButton(frame: CGRect(x: (layer.frame.width/2) - (buttonWidth/2), y: layerHeight - buttonHeight - buttonButtomPadding, width: buttonWidth, height: buttonHeight))
        button.backgroundColor = .white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:1).cgColor
        button.layer.cornerRadius = 5
        button.setTitle("Close", for: .normal)
        button.setTitleColor(UIColor(red:0.14, green:0.25, blue:0.46, alpha:1), for: .normal)
        button.addTarget(self, action: #selector(syncLayerButtonAction), for: .touchUpInside)

        button.tag = 103
        // add to layer that holds content
        layer.addSubview(button)

        let spinnerWidth: CGFloat = 200
        let animationView = LOTAnimationView(name: "spinner2_")
        animationView.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
//        animationView.center = layer.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView .tag = 105
        layer.addSubview(animationView)

        let animationView2 = LOTAnimationView(name: "checked_done_")
        animationView2.frame = CGRect(x: (layer.frame.width/2) - (spinnerWidth/2), y: (layer.frame.height/2) - (spinnerWidth/2), width: spinnerWidth, height: spinnerWidth)
        //        animationView.center = layer.center
        animationView2.contentMode = .scaleAspectFit
        animationView2.loopAnimation = false
        animationView2 .tag = 106
        animationView2.alpha = 0

        layer.addSubview(animationView2)

//        animationView.play()

        // add layer that holds content to gray screen
        view.addSubview(layer)

        // give the view that contains it all (white screen)
        view.tag = 100

        return view
    }

    func beginSyncLoadingAnimation() {
        if let animationView = self.view.viewWithTag(105) as? LOTAnimationView {
            animationView.play()
        }
    }

    func endSyncLoadingAnimation() {
        if let loadingView = self.view.viewWithTag(105) as? LOTAnimationView, let done = self.view.viewWithTag(106) as? LOTAnimationView {
            loadingView.removeFromSuperview()
            done.alpha = 1
            done.play()
        }
    }

    func updateSyncDescription(text: String) {
        if let viewWithTag = self.view.viewWithTag(102) as? UILabel {
            viewWithTag.attributedText = getSycDescriptionText(text: text)
        }
    }

    func updateSyncTitle(text: String) {
        if let viewWithTag = self.view.viewWithTag(101) as? UILabel {
            viewWithTag.attributedText = getSycnTitleText(text: text)
        }
    }

    func updateSyncButtonTitle(text: String) {
        if let viewWithTag = self.view.viewWithTag(103) as? UIButton {
            viewWithTag.setTitle(text, for: .normal)
        }
    }

    func disableSyncViewButton() {
        if let viewWithTag = self.view.viewWithTag(103) as? UIButton {
            viewWithTag.isEnabled = false
        }
    }

    func enableSyncViewButton() {
        if let viewWithTag = self.view.viewWithTag(103) as? UIButton {
            viewWithTag.isEnabled = true
        }
    }

    func getSycDescriptionText(text: String) ->  NSMutableAttributedString {
        let textContent = text
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.29
        textString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: textRange)
        return textString
    }

    func getSycnTitleText(text: String) ->  NSMutableAttributedString {
        let textContent = text
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 22)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.18
        textString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: textRange)
        return textString
    }

    @objc func syncLayerButtonAction(sender: UIButton!) {
        // removes the sync view by removing the white screen view that contains the other views
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
}
