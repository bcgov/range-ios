//
//  TesterTypePrompt.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-03-06.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Lottie

enum TesterType {
    case RangeStaff
    case AppleReviewer
}

class TesterTypePrompt: CustomModal {
    
    // MARK: Variables
    var completion: ((_ type: TesterType) -> Void)?
    
    // MARK: Outlests
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var appleReviewerContainer: UIView!
    @IBOutlet weak var appleReviewerIcon: UIImageView!
    @IBOutlet weak var appleReviewerLabel: UILabel!
    @IBOutlet weak var appleReviewerButton: UIButton!
    
    @IBOutlet weak var rangeStaffContainer: UIView!
    @IBOutlet weak var rangeStaffIcon: UIImageView!
    @IBOutlet weak var rangeStaffLabel: UILabel!
    @IBOutlet weak var rangeStaffButton: UIButton!
    
    @IBOutlet weak var animationContainer: UIView!
    
    @IBAction func appleReviewerSelected(_ sender: Any) {
        if let completion = self.completion {
            self.remove()
            return completion(.AppleReviewer)
        }
    }
    
    @IBAction func rangeStaffSelected(_ sender: Any) {
        if let completion = self.completion {
            self.remove()
            return completion(.RangeStaff)
        }
    }
    
    // MARK: Entry Point
    func initialize(completion: @escaping(_ tester: TesterType) -> Void) {
        self.completion = completion
        setSmartSizingWith(percentHorizontalPadding: 35, percentVerticalPadding: 35)
        setFixed(width: 400, height: 600)
        style()
        setContent()
        present()
        showAnimation()
    }
    
    func setContent() {
        self.title.text = "Who's Testing?"
        self.subtitle.text = "Looks like this version of the MyRangeBC application is currently being tested.\nPlease choose your role and we will direct you to the appropriate login page."
        
        rangeStaffLabel.text = "Range Staff"
        appleReviewerLabel.text = "Apple Reviewer"
        
        rangeStaffIcon.image = UIImage(named: "rangeStafficon")
        appleReviewerIcon.image = UIImage(named: "applereviewericon")
    }
    
    // Mark: Style
    func style() {
        styleModalBox()
        //divider.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
        styleDivider(divider: divider)
        title.font = Fonts.getPrimaryBold(size: 22)
        title.textColor = Colors.active.blue
        
        styleSubHeader(label: title)
        styleFooter(label: subtitle)
        
        styleContainer(view: rangeStaffContainer)
        styleContainer(view: appleReviewerContainer)
        
        styleCustomButtonFill(container: rangeStaffContainer, label: rangeStaffLabel)
        styleCustomButtonFill(container: appleReviewerContainer, label: appleReviewerLabel)
    }
    
    func showAnimation() {
        for subview in animationContainer.subviews {
            subview.removeFromSuperview()
        }
        let animationView = LOTAnimationView(name: "typing")
        animationView.frame = animationContainer.frame
        animationView.center.y = animationContainer.center.y
        animationView.center.x = animationContainer.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.alpha = 1
        animationContainer.addSubview(animationView)
        
        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: animationContainer.frame.width),
            animationView.heightAnchor.constraint(equalToConstant: animationContainer.frame.height),
            animationView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor),
            ])
        animationView.play()
    }
}
