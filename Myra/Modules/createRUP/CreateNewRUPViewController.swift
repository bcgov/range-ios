//
//  CreateNewRUPViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class CreateNewRUPViewController: UIViewController {

    // MARK: Outlets
    // TOP
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var ranchNameAndNumberLabel: UILabel!
    @IBOutlet weak var saveToDraftButton: UIButton!

    // Side Menu
    @IBOutlet weak var basicInfoLabel: UILabel!
    @IBOutlet weak var basicInfoButton: UIButton!
    @IBOutlet weak var basicInfoBoxImage: UIImageView!

    @IBOutlet weak var pasturesLabel: UILabel!
    @IBOutlet weak var pasturesButton: UIButton!
    @IBOutlet weak var pasturesBoxImage: UIImageView!

    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var scheduleBoxImage: UIImageView!

    @IBOutlet weak var ministersIssuesLabel: UILabel!
    @IBOutlet weak var ministersIssuesButton: UIButton!
    @IBOutlet weak var ministersIssuesBoxImage: UIImageView!

    @IBOutlet weak var invasivePlantsLabel: UILabel!
    @IBOutlet weak var invasivePlantsButton: UIButton!
    @IBOutlet weak var invasivePlantsBoxImage: UIImageView!

    @IBOutlet weak var additionalRequirementsLabel: UILabel!
    @IBOutlet weak var additionalRequirementsButton: UIButton!
    @IBOutlet weak var additionalRequirementsBoxImage: UIImageView!

    @IBOutlet weak var managementLabel: UILabel!
    @IBOutlet weak var managementButton: UIButton!
    @IBOutlet weak var managementBoxImage: UIImageView!

    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapInfoBoxImage: UIImageView!

    @IBOutlet weak var reviewAndSubmitLabel: UILabel!
    @IBOutlet weak var reviewAndSubmitButton: UIButton!
    @IBOutlet weak var reviewAndSubmitBoxImage: UIImageView!

    // Body
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Mark: Outlet Actions
    @IBAction func saveToDraftAction(_ sender: UIButton) {
    }

    @IBAction func basicInfoAction(_ sender: UIButton) {
    }
    @IBAction func pasturesAction(_ sender: UIButton) {
    }
    @IBAction func scheduleAction(_ sender: UIButton) {
    }
    @IBAction func ministersIssuesAction(_ sender: UIButton) {
    }
    @IBAction func invasivePlantsAction(_ sender: UIButton) {
    }
    @IBAction func additionalRequirementsAction(_ sender: UIButton) {
    }
    @IBAction func managementAction(_ sender: UIButton) {
    }
    @IBAction func mapAction(_ sender: UIButton) {
    }
    @IBAction func reviewAndSubmitAction(_ sender: UIButton) {
    }


}
