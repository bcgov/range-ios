//
//  tagImage.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-01.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Extended

class TagImage: UIView, Theme {

    override func didMoveToWindow() {
        style()
    }

    let whiteScreenTag = 2231
    let animationDuration = 0.5
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    let whiteScreenAlpha: CGFloat = 0.9

    // MARK: Variables
    var photo: RangePhoto?
    var parent: UIViewController?
    var callBack: (() -> Void )?

    // MARK: outlets
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var tagHeader: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var locationHeader: UILabel!
    @IBOutlet weak var timeStampField: UITextField!
    @IBOutlet weak var timeStampHeader: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ranHeader: UILabel!
    @IBOutlet weak var ranField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var headingBg: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    

    func setup(with photo: RangePhoto) {
        self.photo = photo
        autoFill()
    }

    @IBAction func saveAction(_ sender: UIButton) {
        guard let photo = self.photo else {return}
        let conent = tagField.text ?? ""
        let ran = ranField.text ?? ""
        photo.set(content: conent, ran: ran)
        self.removeWhiteScreen()
        self.removeFromSuperview()
//        closingAnimation {
//            self.removeWhiteScreen()
//            self.removeFromSuperview()
//            if let completion = self.callBack {
//                return completion()
//            }
//        }
    }

//    @objc func selectRAN() {
//        guard let parent = self.parent, let base = parent as? BaseViewController else {return}
//        let vm = ViewManager()
//        let lookup = vm.lookup
//        let rans = Options.shared.getRANLookup()
//        lookup.setupSimple(objects: rans) { (done, selected) in
//            if let ran = selected {
//                self.ranField.text = ran.display
//            }
//        }
//        base.showPopUp(vc: lookup, on: ranField.layer, inView: ranField)
//    }

    @IBAction func chooseRan(_ sender: UIButton) {
        guard let parent = self.parent, let base = parent as? BaseViewController else {return}
        let vm = ViewManager()
        let lookup = vm.lookup
        let rans = Options.shared.getRANLookup()
        lookup.setupSimple(objects: rans) { (done, selected) in
            if let ran = selected {
                self.ranField.text = ran.display
            }
        }
        base.showPopUp(vc: lookup, on: sender)
    }


    func autoFill() {
        guard let photo = self.photo else {return}
        if photo.content.isEmpty, let image = photo.getImage() {
            self.tagField.text = getContent(of: image)
        } else {
            self.tagField.text = photo.content
        }
        let headingInt: Int = Int(photo.trueHeading.roundToDecimal(0))
        self.headingLabel.text = "\(headingInt)°"
        self.locationField.text = ("\(photo.lat.roundToDecimal(5)), \(photo.long.roundToDecimal(5))")
        if let timestamp = photo.timeStamp {
            self.timeStampField.text = timestamp.stringWithTime()
        }
        self.ranField.text = photo.ran
        if let image = photo.getImage() {
            self.imageView.image = image
        }

        if photo.trueHeading == -1 {
            headingBg.alpha = 0
        }
    }

    func style() {
        styleContainer(view: headingBg)
        makeCircle(view: headingBg)
        styleFieldHeader(label: headingLabel)
        styleFieldHeader(label: timeStampHeader)
        styleFieldHeader(label: locationHeader)
        styleFieldHeader(label: ranHeader)
        styleFieldHeader(label: tagHeader)
        styleInputField(field: timeStampField, editable: false, height: fieldHeight)
        styleInputField(field: locationField, editable: false, height: fieldHeight)
        styleInputField(field: tagField, editable: true, height: fieldHeight)
        styleInputField(field: ranField, editable: true, height: fieldHeight)
        styleContainer(layer: self.layer)
        styleContainer(layer: imageView.layer)
        styleFillButton(button: saveButton)
        backgroundColor = Colors.primaryBg

//        ranField.addTarget(self, action: #selector(selectRAN), for: UIControl.Event.touchDown)
    }

    public func show(with photo: RangePhoto, in viewController: UIViewController, then: @escaping () -> Void) {
        self.callBack = then
        self.alpha = invisibleAlpha
        self.photo = photo
        self.parent = viewController
        guard let view = viewController.view else {return}
        self.frame = CGRect(x: 0, y: 0, width: view.frame.width - 30, height: view.frame.height - 30)
        self.center.x = view.center.x
        self.center.y = view.center.y
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        view.addSubview(self)
        self.alpha = invisibleAlpha

        // Add constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        
        // White screen
        let bg = whiteScreen(for: view)
        bg.alpha = invisibleAlpha
        view.insertSubview(bg, belowSubview: self)
        view.layoutIfNeeded()
        let isWidthLarger = view.frame.width > view.frame.height

        if isWidthLarger {
            NSLayoutConstraint.activate([
                bg.widthAnchor.constraint(equalTo: view.widthAnchor),
                bg.heightAnchor.constraint(equalTo:  view.widthAnchor),
                bg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                bg.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                ])
        } else {
            NSLayoutConstraint.activate([
                bg.widthAnchor.constraint(equalTo: view.heightAnchor),
                bg.heightAnchor.constraint(equalTo:  view.heightAnchor),
                bg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                bg.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                ])
        }

        self.autoFill()
        self.layoutIfNeeded()
        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
        }) { (done) in
            self.openingAnimation {
                Loading.shared.end()
            }
        }
    }

    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.visibleAlpha
            self.layoutIfNeeded()
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
    func whiteScreen(for view: UIView) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.center.y = view.center.y
        view.center.x = view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: whiteScreenAlpha)
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
