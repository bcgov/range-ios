//
//  BaseCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-28.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
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
