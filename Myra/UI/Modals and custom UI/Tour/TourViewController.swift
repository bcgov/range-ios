//
//  TourViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-08.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class TourViewController: UIViewController, Theme {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!

    @IBOutlet weak var descLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var descLabel: UILabel!

    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeights: NSLayoutConstraint!
    @IBOutlet weak var skipHight: NSLayoutConstraint!
    
    var backCallback: (()->Void)?
    var nextCallback: (()->Void)?
    var skipCallback: (()->Void)?

    var actionCallback: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        style()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let callback = actionCallback {
            return callback()
        }
    }

    @IBAction func backAction(_ sender: UIButton) {
        back()
    }


    @IBAction func nextAction(_ sender: UIButton) {
        next()
    }


    @IBAction func skipAction(_ sender: UIButton) {
        skip()
    }

    func skip() {
        guard let callback = self.skipCallback else {return}
        actionCallback = callback
        self.dismiss(animated: true)
    }

    func back() {
        guard let callback = self.backCallback else {return}
        actionCallback = callback
        self.dismiss(animated: true)
    }

    func next() {
        guard let callback = self.nextCallback else {return}
        actionCallback = callback
        self.dismiss(animated: true)
    }

    func setup(header: String, desc: String, backgroundColor: UIColor, textColor: UIColor, hasPrev: Bool, hasNext: Bool, onBack: @escaping ()->Void, onNext: @escaping ()-> Void, onSkip: @escaping ()-> Void) {
        self.backCallback = onBack
        self.nextCallback = onNext
        self.skipCallback = onSkip
        self.actionCallback = onNext
        self.titleLabel.text = header
        self.descLabel.text = desc
        style()
        if !hasPrev {
            backButton.isHidden = true
        }

        if !hasNext {
            nextButton.setTitle("Done", for: .normal)
        }

        self.descLabel.textColor = textColor
        self.titleLabel.textColor = textColor

    }

    func style() {
        styleHollowButton(button: backButton)
        styleHollowButton(button: nextButton)
        self.backButton.setTitle("Back", for: .normal)
        self.nextButton.setTitle("Next", for: .normal)
        self.descLabel.textColor = UIColor.white
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = Fonts.getPrimaryBold(size: 22)
        self.descLabel.font = Fonts.getPrimary(size: 17)
        if let descL = self.descLabel, let text = descL.text, let height = descLabelHeight {
            height.constant = text.height(withConstrainedWidth: descL.frame.width, font: Fonts.getPrimary(size: 17)) + 16
        }
        backButton.isHidden = false

        self.view.layoutIfNeeded()
    }

    func styleButton(button: UIButton, bg: UIColor, borderColor: CGColor, titleColor: UIColor) {
        button.layer.cornerRadius = 5
        button.backgroundColor = bg
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor
        button.setTitleColor(titleColor, for: .normal)
    }

}
