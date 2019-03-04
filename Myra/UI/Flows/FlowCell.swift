//
//  FlowCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowCell: UICollectionViewCell, Theme {
    
    var model: FlowHelperModel?
    var nextClicked: (() -> Void)?
    var previousClicked: (() -> Void)?
    var closeClicked: (() -> Void)?
    
    func initialize(for model: FlowHelperModel, nextClicked: @escaping () -> Void, previousClicked: @escaping () -> Void, closeClicked: @escaping () -> Void) {
        self.model = model
        self.nextClicked = nextClicked
        self.previousClicked = previousClicked
        self.closeClicked = closeClicked
        whenInitialized()
    }
    
    func whenInitialized() {}
    
    func fadeLabelMessage(label: UILabel, text: String) {
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
            label.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = text
            // fade in warning text
            UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
                label.textColor = Colors.accent.red
                label.alpha = 1
                self.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), delay: 3, animations: {
                    // fade out text
                    label.alpha = 0
                    self.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: SettingsManager.shared.getShortAnimationDuration(), animations: {
                        label.textColor = originalTextColor
                        label.alpha = 1
                        self.layoutIfNeeded()
                    })
                })
            })
        }
    }
}
