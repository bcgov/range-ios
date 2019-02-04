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

    @IBOutlet weak var otherFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var boxOneHeight: NSLayoutConstraint!
    @IBOutlet weak var boxTwoHeight: NSLayoutConstraint!
    @IBOutlet weak var boxThreeHeight: NSLayoutConstraint!
    @IBOutlet weak var boxFourHeight: NSLayoutConstraint!
    
    // MARK: Outlet Actions
    @IBAction func optionOneAction(_ sender: UIButton) {
        guard let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(equipmentAndVehiclesParking: !invasivePlants.equipmentAndVehiclesParking)
        autoFill()
    }

    @IBAction func optionTwoAction(_ sender: UIButton) {
        guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(beginInUninfestedArea: !invasivePlants.beginInUninfestedArea)
        autoFill()
    }

    @IBAction func optionThreeAction(_ sender: UIButton) {
        guard let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(undercarrigesInspected: !invasivePlants.undercarrigesInspected)
        autoFill()
    }

    @IBAction func optionFourAction(_ sender: UIButton) {
        guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(revegetate: !invasivePlants.revegetate)
        autoFill()
    }

    @IBAction func optionFiveAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        // if button is off, image is nill
        if boxFiveIcon.image == nil {
            showOtherOption()
        } else {
            if textView.text.isEmpty {
                hideOtherOption()
                return
            }
            parent.showAlert(title: "Are you sure?", description: "This action removes the text description you've entered", yesButtonTapped: {
                self.hideOtherOption()
            }) {}
        }
    }

    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Invasive Plants", desc: InfoTips.invasivePlants)
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

    override func setup(mode: FormMode, rup: Plan) {
        createObjectIfDoesntExist()
        self.mode = mode
        self.plan = rup
        style()
        autoFill()
    }

    func createObjectIfDoesntExist() {
        guard let plan = self.plan else {return}
        if plan.invasivePlants.isEmpty {
            let new = InvasivePlants()
            do {
                let realm = try Realm()
                try realm.write {
                    plan.invasivePlants.append(new)
                }
            } catch {
                Logger.fatalError(message: LogMessages.databaseWriteFailure)
            }
            RealmRequests.saveObject(object: new)
        }
    }

    func autoFill() {
        guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        style(box: boxOneIcon, on: invasivePlants.equipmentAndVehiclesParking)
        style(box: boxTwoIcon, on: invasivePlants.beginInUninfestedArea)
        style(box: boxThreeIcon, on: invasivePlants.undercarrigesInspected)
        style(box: boxFourIcon, on: invasivePlants.revegetate)
//        style(box: boxFiveIcon, on: !invasivePlants.other.isEmpty)
//        textView.text = invasivePlants.other
        if invasivePlants.other.isEmpty {
            hideOtherOption()
        } else {
            showOtherOption()
        }
    }

    func showOtherOption() {
         guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        textView.text = invasivePlants.other
        otherFieldHeight.constant = 80
        style(box: boxFiveIcon, on: true)
    }

    func hideOtherOption() {
        guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(other: "")
        textView.text = ""
        otherFieldHeight.constant = 0
        style(box: boxFiveIcon, on: false)
    }
    
    func adjustBoxHeights() {
        boxOneHeight.constant = optionOne.text?.height(withConstrainedWidth: optionOne.frame.width, font: optionOne.font) ?? boxOneHeight.constant
        
        boxTwoHeight.constant = optionTwo.text?.height(withConstrainedWidth: optionTwo.frame.width, font: optionTwo.font) ?? boxTwoHeight.constant
        
        boxThreeHeight.constant = optionThree.text?.height(withConstrainedWidth: optionThree.frame.width, font: optionThree.font) ?? boxThreeHeight.constant
        
        boxFourHeight.constant = optionFour.text?.height(withConstrainedWidth: optionFour.frame.width, font: optionFour.font) ?? boxFourHeight.constant
    }

    // MARK: Style
    func style() {
        styleHeader(label: titleLabel, divider: divider)
        titleLabel.increaseFontSize(by: -4)
        styleSubHeader(label: subtitle)
        styleTextviewInputField(field: textView)
        styleBody(label: optionOne)
        styleBody(label: optionTwo)
        styleBody(label: optionThree)
        styleBody(label: optionFour)
        styleBody(label: optionFive)
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
            textView.isEditable = false
        }
        adjustBoxHeights()
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
         guard  let plan = self.plan, let invasivePlants = plan.invasivePlants.first else {return}
        invasivePlants.setValue(other: textView.text)
//        style(box: boxFiveIcon, on: !textView.text.isEmpty)
    }
}
