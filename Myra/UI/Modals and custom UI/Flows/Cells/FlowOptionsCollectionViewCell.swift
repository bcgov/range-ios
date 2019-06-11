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
    @IBOutlet weak var subtitleHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomDivider: UIView!
    
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
            titleLabel.text = "Add Recommendation"
            subtitleLabel.text = "Add your recommendation to this range use plan. If changes are required select \"Request Changes\" If the plan is ready for decision prepare your recommendation package"
        case .SubmittedForReview:
            titleLabel.text = "Provide Feedback"
            subtitleLabel.text = "Respond to the agreement holder by selecting \"Request Changes\" or \"Recommend For Submission\"."
        case .StandsReview:
            titleLabel.text = "Review Amendment"
            subtitleLabel.text = "Review this range use plan minor amendment."
        case .RecommendReady:
            titleLabel.text = "Add Decision"
            subtitleLabel.text = "Once the DM has made their decision add the decision to the range use plan using the options below."
        case .RecommendNotReady:
            titleLabel.text = "Add Decision"
            subtitleLabel.text = "Once the DM has made their decision add the decision to the range use plan using the options below."
        }
        
        if let subtitleText = subtitleLabel.text {
            subtitleHeight.constant = subtitleText.height(for: subtitleLabel)
        }
    }
    
    // MARK: Style
    func style() {
        styleFlowTitle(label: titleLabel)
        styleFlowSubTitle(label: subtitleLabel)
        styleGreyDivider(divider: bottomDivider)
        styleGreyDivider(divider: divider)
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
