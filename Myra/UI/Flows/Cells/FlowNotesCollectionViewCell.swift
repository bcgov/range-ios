//
//  FlowNotesCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowNotesCollectionViewCell: FlowCell {
    
    // MARK: Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var checkBoxSection: UIView!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var checkBox: UIView!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        guard let model = self.model else {return}
        self.endEditing(true)
        if FlowHelper.shared.statusChangeNeedsToBeCommunicated(forModel: model) {
            if let communicatedChange = model.hasCommunicatedStatusChange {
                if !communicatedChange {
                    fadeLabelMessage(label: checkBoxLabel, text: checkBoxLabel.text ?? "")
                    return
                }
            } else {
                fadeLabelMessage(label: checkBoxLabel, text: checkBoxLabel.text ?? "")
                return
            }
        }
        if let callback = nextClicked {
            return callback()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.endEditing(true)
        if let callback = previousClicked {
            return callback()
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        if let callback = closeClicked {
            return callback()
        }
    }
    
    @IBAction func checkBoxAction(_ sender: UIButton) {
        guard let model = self.model else {return}
        if let existing = model.hasCommunicatedStatusChange {
            model.hasCommunicatedStatusChange = !existing
        } else {
            model.hasCommunicatedStatusChange = true
        }
        refershCheckBox()
    }
    
    // MARK: Initialization
    override func whenInitialized() {
        setupNotifications()
        style()
        autofill()
        textView.delegate = self
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(flowOptionChanged), name: .flowOptionSelectionChanged, object: nil)
    }
    
    @objc func flowOptionChanged(_ notification:Notification) {
        style()
        autofill()
    }
    
    func autofill() {
        guard let model = self.model else {return}
        
        textView.text = model.notes
        
        // Show/ hide checkbox section based on flow
        
        if let checkBoxText = FlowHelper.shared.statusChangeCommunicationTextFor(forModel: model) {
            checkBoxLabel.text = checkBoxText
        }
        
        if FlowHelper.shared.statusChangeNeedsToBeCommunicated(forModel: model) {
            showCheckBoxSection()
        } else {
            hideCheckBoxSection()
        }
        
        refershCheckBox()
        
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            title.text = ""
            subtitle.text = ""
        case .SubmittedForReview:
            title.text = ""
            subtitle.text = ""
        case .StandsReview:
            title.text = ""
            subtitle.text = ""
        case .RecommendReady:
            title.text = ""
            subtitle.text = ""
        case .RecommendNotReady:
            title.text = ""
            subtitle.text = ""
        }
        
        title.text = "Title"
        subtitle.text = "Subtitle"
        
    }
    
    func showCheckBoxSection() {
        self.checkBoxSection.isHidden = false
    }
    
    func hideCheckBoxSection() {
         self.checkBoxSection.isHidden = true
    }

    // MARK: Style
    func style() {
        styleCheckBoxInitial()
        styleSubHeader(label: title)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
        styleTextviewInputField(field: textView)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
    }
    
    func styleCheckBoxInitial() {
        checkBox.layer.borderWidth = 1
        checkBox.layer.borderColor = Colors.active.blue.cgColor
        checkBox.backgroundColor = Colors.technical.backgroundTwo
        checkboxImageView.image = nil
        makeCircle(view: checkBox)
        styleFieldHeader(label: checkBoxLabel)
    }
    
    func refershCheckBox() {
        guard let model = self.model else {return}
        if let hasCommunicatedChange = model.hasCommunicatedStatusChange {
            if hasCommunicatedChange {
                styleCheckBoxOn()
            } else {
                styleCheckBoxOff()
            }
        }
    }
    
    func styleCheckBoxOn() {
        checkboxImageView.alpha = 1
        checkboxImageView.image = #imageLiteral(resourceName: "icon_check")
    }
    
    func styleCheckBoxOff() {
        checkboxImageView.alpha = 0
        checkboxImageView.image = nil
    }

}

// MARK: Notes
extension FlowNotesCollectionViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let model = self.model, let text = textView.text else {return}
        model.notes = text
    }
}
