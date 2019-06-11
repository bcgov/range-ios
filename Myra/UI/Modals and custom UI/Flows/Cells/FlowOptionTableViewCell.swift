//
//  FlowOptionTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowOptionTableViewCell: UITableViewCell, Theme {
    // MARK: Variables
    var option: FlowOption?
    var model: FlowHelperModel?
    
    // MARK: Outlets
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var indicatorIcon: UIImageView!
    
    // MARK: Outlet Actions
    @IBAction func selectAction(_ sender: UIButton) {
        guard let model = self.model, let option = self.option else {return}
        model.selectedOption = option
        notifyFlowOptionChanged()
    }
    
    // MARK: Notifications
    func notifyFlowOptionChanged() {
        NotificationCenter.default.post(name: .flowOptionSelectionChanged, object: nil)
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(flowOptionChanged), name: .flowOptionSelectionChanged, object: nil)
    }
    
    @objc func flowOptionChanged(_ notification: Notification) {
        style()
    }
    
    // MARK: Entry Point
    func initialize(option: FlowOption, for model: FlowHelperModel) {
        self.option = option
        self.model = model
        self.label.text = FlowHelper.shared.getTitleFor(option: option)
        self.descriptionLabel.text = FlowHelper.shared.getSubtitleFor(option: option)
        setupNotifications()
        style()
    }
    
    // MARK: Styles
    func style() {
        guard let model = self.model else {return}
        styleFlowOptionName(label: label)
        styleFlowOptionDescription(label: descriptionLabel)
        makeCircle(view: indicator)
        indicator.layer.borderWidth = 1
        indicator.layer.borderColor = Colors.active.blue.cgColor
        
        if let selectedOption = model.selectedOption, selectedOption == option {
            styleSelected()
        } else {
            styleUnselected()
        }
    }
    
    func styleSelected() {
        indicatorIcon.alpha = 1
        indicatorIcon.image = UIImage(named: "checkGreen")
        indicator.layer.borderColor = UIColor.clear.cgColor
    }
    
    func styleUnselected() {
        indicatorIcon.alpha = 0
        indicator.layer.borderColor = Colors.active.blue.cgColor
    }
}
