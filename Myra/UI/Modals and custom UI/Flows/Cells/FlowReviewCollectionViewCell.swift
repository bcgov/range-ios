//
//  FlowReviewCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowReviewCollectionViewCell: FlowCell {
    // MARK: Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        if let callback = nextClicked {
            return callback()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let callback = previousClicked {
            return callback()
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        if let callback = closeClicked {
            return callback()
        }
    }
    
    // MARK: Initialization
    override func whenInitialized() {
        style()
        autofill()
    }
    
    func autofill() {
        guard let model = self.model else {return}
        textView.isEditable = false
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            title.text = "Confirm Recommendation"
            textView.text = "You’re ready to submit this range use plan recommendation. Your explanatory note will be viewable by all agreement holders.\nIf you selected to make a recommendation it will only be viewable to range staff."
        case .SubmittedForReview:
            title.text = "Confirm Feedback"
            textView.text = "You’re ready to submit this range use plan feedback. Your explanatory note will be viewable by all agreement holders"
        case .StandsReview:
            title.text = "Confirm Review"
            textView.text = "You’re ready to submit this amendment review. Your explanatory note will be viewable by all agreement holders"
            
        case .RecommendReady:
            title.text = "Confirm Decision"
            textView.text = "You’re ready to submit this range use plan decision. Your explanatory note will be viewable by all agreement holders and range staff."
        case .RecommendNotReady:
            title.text = "Confirm Decision"
            textView.text = "You’re ready to submit this range use plan decision. Your explanatory note will be viewable by all agreement holders and range staff."
        }        
    }
    
    // MARK: Style
    func style() {
        textView.isEditable = false
        styleSubHeader(label: title)
        styleDivider(divider: divider)
        styleFooter(textView: textView)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
    }
    
}
