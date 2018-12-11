//
//  TourStart.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class TourStart: UIView, Theme {

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
        self.parent = vc
        self.callBack = completion
        style()
        self.alpha = invisibleAlpha
        self.isUserInteractionEnabled = false
        position(then: {
            self.isUserInteractionEnabled = true
        })
    }

    // MARK: Styles
    func style() {
        addShadow(layer: self.layer)
        title.font = Fonts.getPrimaryBold(size: 27)
        title.textColor = UIColor.black
        body.font = Fonts.getPrimaryMedium(size: 17)
        styleFillButton(button: beginButton)
    }

    // MARK: Positioning/ displaying
    func position(then: @escaping ()-> Void) {
        guard let vc = self.parent else {return}
        self.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        self.center.x = vc.view.center.x
        self.center.y = vc.view.center.y
        self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        self.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(self)

        // Add constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 390),
            self.heightAnchor.constraint(equalToConstant: 400),
            self.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        // White screen
        let bg = whiteScreen(for: vc)
        bg.alpha = invisibleAlpha
        vc.view.insertSubview(bg, belowSubview: self)
        NSLayoutConstraint.activate([
            bg.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
            bg.heightAnchor.constraint(equalTo:  vc.view.heightAnchor),
            bg.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ])
        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
            self.openingAnimation {
                return then()
            }
        })
    }

    // MARK: Displaying animations
    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }

    func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.invisibleAlpha
        }) { (done) in
            then()
        }
    }


    // MARK: White Screen
    func whiteScreen(for vc: UIViewController) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height))
        view.center.y = vc.view.center.y
        view.center.x = vc.view.center.x
        view.backgroundColor = Colors.active.blue.withAlphaComponent(0.2)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let parent = parent else {return}
        if let viewWithTag = parent.view.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }
}
