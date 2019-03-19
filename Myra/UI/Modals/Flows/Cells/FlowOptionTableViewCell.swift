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
    
    @objc func flowOptionChanged(_ notification:Notification) {
        style()
    }
    
    // MARK: Entry Point
    func initialize(option: FlowOption, for model: FlowHelperModel) {
        self.option = option
        self.model = model
        self.label.text = option.rawValue.convertFromCamelCase()
        setupNotifications()
        style()
    }
    
    // MARK: Styles
    func style() {
        guard let model = self.model else {return}
        
        styleFieldHeader(label: label)
        label.increaseFontSize(by: 3)
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
        indicator.backgroundColor = Colors.active.blue
    }
    
    func styleUnselected() {
        indicator.backgroundColor = Colors.technical.backgroundTwo
    }
    
}
