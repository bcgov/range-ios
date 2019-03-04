//
//  FlowOptionsCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowOptionsCollectionViewCell: FlowCell {
    
    // Variables
    var options: [FlowOption] = [FlowOption]()
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Outlet Actions
    @IBAction func nextAction(_ sender: UIButton) {
        guard let model = self.model else {return}
        if model.selectedOption == nil {
            fadeLabelMessage(label: subtitleLabel, text: "Please select on option.")
            return
        }
        if let callback = nextClicked {
            return callback()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let callback = closeClicked {
            return callback()
        }
    }
    
    // MARK: Initialization
    override func whenInitialized() {
        style()
        autofill()
        setupTableView()
    }
    
    func autofill() {
        guard let model = self.model else {return}
        options = FlowHelper.shared.optionsFor(status: model.initiatingFlowStatus, isInitial: model.isInitial)
        
        switch model.initiatingFlowStatus {
        case .SubmittedForFinalDecision:
            titleLabel.text = ""
            subtitleLabel.text = ""
        case .SubmittedForReview:
            titleLabel.text = ""
            subtitleLabel.text = ""
        case .StandsReview:
            titleLabel.text = ""
            subtitleLabel.text = ""
        case .RecommendReady:
            titleLabel.text = ""
            subtitleLabel.text = ""
        case .RecommendNotReady:
            titleLabel.text = ""
            subtitleLabel.text = ""
        }
        
        titleLabel.text = "Title"
        subtitleLabel.text = "Subtitle"
    }
    
    // MARK: Style
    func style() {
        styleSubHeader(label: titleLabel)
        styleFooter(label: subtitleLabel)
        styleDivider(divider: divider)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: nextButton)
    }

}

extension FlowOptionsCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        register(cell: "FlowOptionTableViewCell")
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getOptionCell(indexPath: IndexPath) -> FlowOptionTableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "FlowOptionTableViewCell", for: indexPath) as! FlowOptionTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else {return UITableViewCell()}
        let cell = getOptionCell(indexPath: indexPath)
        cell.initialize(option: options[indexPath.row], for: model)
        return cell
    }
    
}
