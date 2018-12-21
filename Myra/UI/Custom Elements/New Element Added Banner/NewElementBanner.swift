//
//  NewElementBanner.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-10.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class NewElementBanner: UIView, Theme {

    @IBOutlet weak var label: UILabel!

    // MARK: Variables
    var displayDuration: TimeInterval = 3
    var animationDuration: TimeInterval = 0.2

    // MARK: Optionals
    var originY: CGFloat?
    var originX: CGFloat?

    // MARK: Constants
    let width: CGFloat = 180
    let height: CGFloat = 42

    func show(x: CGFloat , y: CGFloat , duration: TimeInterval? = 1 ) {
        style()
        if let duration = duration {
            self.displayDuration = duration
        }
        self.originY = y
        self.originX = x

        beginDisplayAnimation()
    }

    func beginDisplayAnimation() {
        positionPreAnimation()
        UIView.animate(withDuration: animationDuration, animations: {
            self.positionDispayed()
        }) { (done) in
            self.beginDismissAnimation()
        }
    }

    func positionDispayed() {
        guard let originY = self.originY, let originX = self.originX else{return}
        self.frame = CGRect(x: (originX - (width/2)), y: (originY - height), width: width, height: height)
        layoutIfNeeded()
    }

    func positionPreAnimation() {
        guard let originY = self.originY, let originX = self.originX else{return}
        self.frame = CGRect(x: (originX - (width/2)), y: (originY + height), width: width, height: height)
        layoutIfNeeded()
    }

    func beginDismissAnimation() {
        UIView.animate(withDuration: animationDuration, delay: (displayDuration + animationDuration), animations: {
            self.positionPreAnimation()
        }) { (done) in
            self.removeFromSuperview()
        }
    }

    func style() {
        styleContainer(view: self)
        self.backgroundColor = Colors.secondary.withAlphaComponent(0.8)
        label.textColor = UIColor.white
    }
}
