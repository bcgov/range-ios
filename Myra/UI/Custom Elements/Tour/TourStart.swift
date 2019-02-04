//
//  TourStart.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class TourStart: CustomModal {

    // MARK: Constants
    let syncIconTag = 200
    let whiteScreenTag = 201
    let animationDuration = 0.5
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    let whiteScreenAlpha: CGFloat = 0.9
    let successIconSizeIncrease: CGFloat = 80

    // MARK: Variables
    var callBack: ((_ success: Bool) -> Void )?
    var parent: UIViewController?
    var succcess: Bool = false

    // MARK: Outlets
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!

    // MARK: Outlet actions
    @IBAction func beginAction(_ sender: UIButton) {
        guard let callBack = self.callBack else {return}
        self.removeWhiteScreen()
        closingAnimation {
            self.removeFromSuperview()
            return callBack(false)
        }
    }

    @IBAction func skipAction(_ sender: UIButton) {
        guard let callBack = self.callBack else {return}
        self.removeWhiteScreen()
        closingAnimation {
            self.removeFromSuperview()
            return callBack(true)
        }
    }

    // MARK: Setup
    func begin(in vc: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        setFixed(width: 390, height: 400)
        self.parent = vc
        self.callBack = completion
        style()
        self.alpha = invisibleAlpha
        self.isUserInteractionEnabled = false
        self.title.text = "Welcome \(SettingsManager.shared.getUserName())"
        body.text = "Welcome to MyRangeBC.\nHow about a quick tour?"
        position(then: {
            self.isUserInteractionEnabled = true
        })
    }

    // MARK: Styles
    func style() {
        styleModalBox()
        addShadow(layer: self.layer)
        title.font = Fonts.getPrimaryBold(size: 27)
        title.textColor = UIColor.black
        body.font = Fonts.getPrimaryMedium(size: 17)
        styleFillButton(button: beginButton)
        styleHollowButton(button: skipButton)
    }
}
