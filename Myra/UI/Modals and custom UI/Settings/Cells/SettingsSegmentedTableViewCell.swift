//
//  SettingsSegmentedTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-03-19.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class SettingsSegmentedTableViewCell: UITableViewCell, Theme {
    
    // MARK: Variables
    var callback: ((_ selection: String) -> Void )?
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmented: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func segmentSelectionChanged(_ sender: UISegmentedControl) {
        if let callback = self.callback, let selection = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            return callback(selection)
        }
    }
    
    func setup(titleText: String, options: [String], selectedOption: String, toggleCallback: @escaping (_ selection: String)-> Void) {
        self.callback = toggleCallback
        // Autofill
        self.titleLabel.text = titleText
        self.setupSegmentedControl(with: options, initialSelection: selectedOption)
        self.style()
    }
    
    func setupSegmentedControl(with options: [String], initialSelection: String) {
        self.segmented.removeAllSegments()
        for i in 0...(options.count - 1) {
            self.segmented.insertSegment(withTitle: options[i], at: i, animated: true)
            if options[i].lowercased() == initialSelection.lowercased() {
                self.segmented.selectedSegmentIndex = i
            }
        }
    }
    
    func style() {
        let font = Fonts.getPrimary(size: 17)
        segmented.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                for: .normal)
        segmented.tintColor = Colors.switchOn
        styleSubHeader(label: titleLabel)
    }
}
