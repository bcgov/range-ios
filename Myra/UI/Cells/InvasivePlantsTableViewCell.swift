//
//  InvasivePlantsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class InvasivePlantsTableViewCell: BaseFormCell {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitle: UILabel!

    @IBOutlet weak var boxOne: UIView!
    @IBOutlet weak var boxTwo: UIView!
    @IBOutlet weak var boxThree: UIView!
    @IBOutlet weak var boxFour: UIView!
    @IBOutlet weak var boxFive: UIView!

    @IBOutlet weak var boxOneIcon: UIImageView!
    @IBOutlet weak var boxTwoIcon: UIImageView!
    @IBOutlet weak var boxThreeIcon: UIImageView!
    @IBOutlet weak var boxFourIcon: UIImageView!
    @IBOutlet weak var boxFiveIcon: UIImageView!

    @IBOutlet weak var optionOne: UILabel!
    @IBOutlet weak var optionTwo: UILabel!
    @IBOutlet weak var optionThree: UILabel!
    @IBOutlet weak var optionFour: UILabel!
    @IBOutlet weak var optionFive: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var optionOneButton: UIButton!
    @IBOutlet weak var optionTwoButton: UIButton!
    @IBOutlet weak var optionThreeButton: UIButton!
    @IBOutlet weak var optionFourButton: UIButton!
    @IBOutlet weak var optionFiveButton: UIButton!

    @IBAction func optionOneAction(_ sender: UIButton) {
        guard let invasivePlants = rup.invasivePlants.first else {return}
        invasivePlants.setValue(equipmentAndVehiclesParking: !invasivePlants.equipmentAndVehiclesParking)
        autoFill()
    }

    @IBAction func optionTwoAction(_ sender: UIButton) {
        guard let invasivePlants = rup.invasivePlants.first else {return}
        invasivePlants.setValue(beginInUninfestedArea: !invasivePlants.beginInUninfestedArea)
        autoFill()
    }

    @IBAction func optionThreeAction(_ sender: UIButton) {
        guard let invasivePlants = rup.invasivePlants.first else {return}
        invasivePlants.setValue(undercarrigesInspected: !invasivePlants.undercarrigesInspected)
        autoFill()
    }

    @IBAction func optionFourAction(_ sender: UIButton) {
        guard let invasivePlants = rup.invasivePlants.first else {return}
        invasivePlants.setValue(revegetate: !invasivePlants.revegetate)
        autoFill()
    }

    @IBAction func optionFiveAction(_ sender: UIButton) {
        guard let invasivePlants = rup.invasivePlants.first else {return}
    }

    // MARK: Outlet Actions
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: tooltipMinistersIssuesAndActionsTitle, desc: tooltipMinistersIssuesAndActionsDescription)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        createObjectIfDoesntExist()
//        style()
//        autoFill()
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func setup(mode: FormMode, rup: RUP) {
        createObjectIfDoesntExist()
        self.mode = mode
        self.rup = rup
        style()
        autoFill()
    }

    func createObjectIfDoesntExist() {
        if rup.invasivePlants.isEmpty {
            let new = InvasivePlants()
            do {
                let realm = try Realm()
                try realm.write {
                    rup.invasivePlants.append(new)
                }
            } catch {
                fatalError()
            }
            RealmRequests.saveObject(object: new)
        }
    }

    func autoFill() {
        guard let invasivePlants = rup.invasivePlants.first else {return}
        style(box: boxOneIcon, on: invasivePlants.equipmentAndVehiclesParking)
        style(box: boxTwoIcon, on: invasivePlants.beginInUninfestedArea)
        style(box: boxThreeIcon, on: invasivePlants.undercarrigesInspected)
        style(box: boxFourIcon, on: invasivePlants.revegetate)
        style(box: boxFiveIcon, on: !invasivePlants.other.isEmpty)
        textView.text = invasivePlants.other
    }

    // MARK: Style
    func style() {
        styleHeader(label: titleLabel, divider: divider)
        titleLabel.increaseFontSize(by: -4)
        styleSubHeader(label: subtitle)
        styleTextviewInputField(field: textView)
        styleSubHeader(label: optionOne)
        styleSubHeader(label: optionTwo)
        styleSubHeader(label: optionThree)
        styleSubHeader(label: optionFour)
        styleSubHeader(label: optionFive)
        switchOff(box: boxOneIcon)
        switchOff(box: boxTwoIcon)
        switchOff(box: boxThreeIcon)
        switchOff(box: boxFourIcon)
        switchOff(box: boxFiveIcon)

        makeCircle(view: boxOne)
        makeCircle(view: boxTwo)
        makeCircle(view: boxThree)
        makeCircle(view: boxFour)
        makeCircle(view: boxFive)

        boxOne.backgroundColor = Colors.inputBG
        boxTwo.backgroundColor = Colors.inputBG
        boxThree.backgroundColor = Colors.inputBG
        boxFour.backgroundColor = Colors.inputBG
        boxFive.backgroundColor = Colors.inputBG

        if self.mode == .View {
            optionOneButton.isEnabled = false
            optionTwoButton.isEnabled = false
            optionThreeButton.isEnabled = false
            optionFourButton.isEnabled = false
            optionFiveButton.isEnabled = false
        }
    }

    func style(box: UIImageView, on: Bool) {
        if on {
            switchOn(box: box)
        } else {
            switchOff(box: box)
        }
    }

    func switchOff(box: UIImageView) {
        makeCircle(view: box)
         box.image = nil
    }

    func switchOn(box: UIImageView) {
        makeCircle(view: box)
        box.image = UIImage(named: "icon_check")
    }
}

// MARK: Notes
extension InvasivePlantsTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
         guard let invasivePlants = rup.invasivePlants.first else {return}
        invasivePlants.setValue(other: textView.text)
        style(box: boxFiveIcon, on: !textView.text.isEmpty)
    }
}
