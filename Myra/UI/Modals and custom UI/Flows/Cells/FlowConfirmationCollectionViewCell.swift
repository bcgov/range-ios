//
//  FlowConfirmationCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit
import Lottie
class FlowConfirmationCollectionViewCell: FlowCell {

    // MARK: Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var iconHolder: UIView!
    
    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        if let callback = nextClicked {
            return callback()
        }
    }
    
    // MARK: Initialization
    override func whenInitialized() {
        style()
        title.text = "Completed"
    }
    
    // MARK: Style
    func style() {
        styleFlowTitle(label: title)
        styleGreyDivider(divider: divider)
//        styleFillButton(button: nextButton)
    }
    
    func showAnimation() {
        for subview in iconHolder.subviews {
            subview.removeFromSuperview()
        }
        let animationView = LOTAnimationView(name: "checked_done_")
        animationView.frame = iconHolder.frame
        animationView.center.y = iconHolder.center.y
        animationView.center.x = iconHolder.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = false
        animationView.alpha = 1
        iconHolder.addSubview(animationView)
        
        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: iconHolder.frame.width + 88 ),
            animationView.heightAnchor.constraint(equalToConstant: iconHolder.frame.height + 88),
            animationView.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor)
            ])
        animationView.play()
    }
}
