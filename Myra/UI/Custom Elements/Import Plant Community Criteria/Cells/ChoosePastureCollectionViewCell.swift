//
//  ChoosePastureCollectionViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

enum ImportCriteriaOptionsType {
    case Pastures
    case PlantCommunities
    case Criteria
}

class ImportCriteriaObject {
    var plan: RUP
    var pasture: Pasture?
    var plantCommunity: PlantCommunity?
    var RangeReadiness: Bool = true
    var StubbleHeight: Bool = true
    var ShrubUse: Bool = true

    init(for plan: RUP) {
        self.plan = plan
    }

    func selectedSections() ->[PlantCommunityCriteriaFromSection] {
        var returnArray = [PlantCommunityCriteriaFromSection]()
        if self.RangeReadiness {
            returnArray.append(.RangeReadiness)
        }
        if self.StubbleHeight {
            returnArray.append(.StubbleHeight)
        }
        if self.ShrubUse {
            returnArray.append(.ShrubUse)
        }
        return returnArray
    }
}

class ChoosePastureCollectionViewCell: UICollectionViewCell {

    var options: [String] = [String]()
    var type: ImportCriteriaOptionsType = .Pastures
    var object: ImportCriteriaObject?
    var parent: ImportCriteria?

    @IBOutlet weak var tableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()
    }

    func setup(for object: ImportCriteriaObject, type: ImportCriteriaOptionsType, parent: ImportCriteria) {
        self.parent = parent
        self.type = type
        self.object = object
        switch type {
        case .Pastures:
            loadOptions(plan: object.plan)
        case .PlantCommunities:
            if let pasture = object.pasture {
                loadOptions(pasture: pasture)
            }
        case .Criteria:
            loadOptions()
        }
    }

    func loadOptions(plan: RUP? = nil, pasture: Pasture? = nil) {
        options.removeAll()
        if let plan = plan {
            let pastures = plan.pastures
            for element in pastures {
                options.append(element.name)
            }
            self.tableView.reloadData()
            return
        }

        if let pasture = pasture {
            let plantCommunities = pasture.plantCommunities
            for element in plantCommunities {
                options.append(element.name)
            }
            self.tableView.reloadData()
            return
        }

        options = ["Range Readiness", "Stubble Height", "Shrub Use"]
        self.tableView.reloadData()
        return
    }

    // Called from cells
    func selectOption(named: String) {
        guard let object = self.object, let parent = self.parent else {return}
        switch self.type {
        case .Pastures:
            object.pasture = RUPManager.shared.getPastureNamed(name: named, rup: object.plan)
            self.tableView.reloadData()
            parent.showChoosePlantCommunity()
        case .PlantCommunities:
            guard let pasture = object.pasture else {print("Pasture not selected"); return}
            for pc in pasture.plantCommunities where pc.name == named {
                object.plantCommunity = pc
            }
            self.tableView.reloadData()
            parent.showChooseCriteria()
        case .Criteria:
            if named == "Range Readiness" {
                object.RangeReadiness = !object.RangeReadiness
            }

            if named == "Stubble Height" {
                object.StubbleHeight = !object.StubbleHeight
            }

            if named == "Shrub Use" {
                object.ShrubUse = !object.ShrubUse
            }
            self.tableView.reloadData()
        }
    }

}

extension ChoosePastureCollectionViewCell:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ImportCriteriaOptionTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> ImportCriteriaOptionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ImportCriteriaOptionTableViewCell", for: indexPath) as! ImportCriteriaOptionTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.set(name: options[indexPath.row], parent: self, selected: isOptionSelected(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func isOptionSelected(at index: Int) -> Bool {
        let option: String = options[index]
        var seleted = false
        if let object = self.object {
            switch self.type {
            case .Pastures:
                if let pasture = object.pasture, pasture.name == option {
                    seleted = true
                }
            case .PlantCommunities:
                if let pc = object.plantCommunity, pc.name == option {
                    seleted = true
                }
            case .Criteria:
                if option == "Range Readiness" {
                    seleted = object.RangeReadiness
                }

                if option == "Stubble Height" {
                    seleted = object.StubbleHeight
                }

                if option == "Shrub Use" {
                    seleted = object.ShrubUse
                }
            }
        }
        return seleted
    }
}

