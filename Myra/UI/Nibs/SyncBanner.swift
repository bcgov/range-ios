//
//  SyncBanner.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-30.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SyncBanner: UIView, Theme {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    // MARK: Outlets
    @IBOutlet weak var label: UILabel!

    // MARK: Variables
    var displayDuration: TimeInterval = 3
    var animationDuration: TimeInterval = 0.4

    // MARK: Optionals
    var originY: CGFloat?
    var originX: CGFloat?

    // MARK: Constants
    let width: CGFloat = 300
    let height: CGFloat = 60

    func show(message: String, x: CGFloat , y: CGFloat , duration: TimeInterval? = 3 ) {
        style()
        if let duration = duration {
            self.displayDuration = duration
        }
        self.label.text = message
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
        self.frame = CGRect(x: originX, y: originY, width: width, height: height)
        layoutIfNeeded()
    }

    func positionPreAnimation() {
        guard let originY = self.originY, let originX = self.originX else{return}
        self.frame = CGRect(x: (originX - width), y: originY, width: width, height: height)
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
        styleFieldHeader(label: label)
        label.increaseFontSize(by: 2)
    }
}
