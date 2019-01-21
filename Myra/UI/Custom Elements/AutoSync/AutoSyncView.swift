//
//  AutoSyncView.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-21.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit
import Lottie

class AutoSyncView: CustomModal {
    
    // MARK: Outlets
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    
    func initialize() {
        AutoSync.shared.endListener()
        setFixed(width: 390, height: 400)
        style()
        present()
        addSyncIcon()
    }
    
    func addSyncIcon() {
        // add sync icon
        let animationView = LOTAnimationView(name: "sync_icon")
        animationView.frame = iconContainer.frame
        animationView.center.y = iconContainer.center.y
        animationView.center.x = iconContainer.center.x
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        
        iconContainer.addSubview(animationView)
        // add anchors to center and rotate properly
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ])
        animationView.play()
    }

    func style() {
        title.font = Fonts.getPrimaryBold(size: 22)
        title.textColor = Colors.active.blue
        divider.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        waitLabel.font = Fonts.getPrimary(size: 17)
        waitLabel.textColor = Colors.active.blue
    }
}
