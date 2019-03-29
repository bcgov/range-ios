//
//  Tour.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-08.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit


class TourObject {
    var header: String
    var desc: String
    var view: UIView
    var beforePresentation: (()-> Void)?
    var afterPresentation: (()-> Void)?

    init(header: String, desc: String, on view: UIView, beforePresentation: (() -> Void)? = nil , afterPresentation: (() -> Void)? = nil) {
        self.beforePresentation = beforePresentation
        self.afterPresentation = afterPresentation
        self.header = header
        self.desc = desc
        self.view = view
    }
}

class Tour {

    lazy var popoverVC: TourViewController = {
        return UIStoryboard(name: "Tour", bundle: Bundle.main).instantiateViewController(withIdentifier: "Tour") as! TourViewController
    }()

    let topTag = 66610
    let bottomTag = 66611
    let leftTag = 66612
    let rightTag = 66613
    let frameTag = 66614

    let backgroundColor = Colors.active.blue
    var currentController: UIViewController?

    var old: [TourObject] = [TourObject]()

    func initialize(with elements: [TourObject], backgroundColor: UIColor, textColor: UIColor, containerIn controller: UIViewController, then: @escaping () -> Void) {
        let welcomeScreen: TourStart = UIView.fromNib()
        welcomeScreen.begin(in: controller) { (skip) in
            if skip {
                return then()
            } else {
                self.old.removeAll()
                self.show(elements: elements, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
            }
        }
    }

    func show(elements: [TourObject], backgroundColor: UIColor, textColor: UIColor, containedIn controller: UIViewController, then: @escaping () -> Void) {
        var tours = elements
        guard let current = tours.last else {
            self.removeCover()
            self.popoverVC.dismiss(animated: true)
            self.old.removeAll()
            return then()
        }

        if let beforeAction = current.beforePresentation {
            beforeAction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(element: current, containedIn: controller, hasNext: (tours.count > 1 ), backgroundColor: backgroundColor, textColor: textColor, onBack: {
                    self.removeCover()
                    if let prev = self.old.popLast() {
                        tours.append(prev)
                        self.show(elements: tours, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
                    }
                }, onNext: {
                    self.removeCover()
                    self.old.append(current)
                    tours.removeLast()
                    if let afterAction = current.afterPresentation {
                        afterAction()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            self.show(elements: tours, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
                        })
                    } else {
                        self.show(elements: tours, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
                    }
                }, onSkip: {
                    self.removeCover()
                    self.old.removeAll()
                    tours.removeAll()
                    return then()
                })
            }
        } else {
            show(element: current, containedIn: controller, hasNext: (tours.count > 1 ), backgroundColor: backgroundColor, textColor: textColor, onBack: {
                self.removeCover()
                if let prev = self.old.popLast() {
                    tours.append(prev)
                    self.show(elements: tours, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
                }
            }, onNext: {
                self.removeCover()
                self.old.append(current)
                tours.removeLast()
                if let afterAction = current.afterPresentation {
                    afterAction()
                }
                self.show(elements: tours, backgroundColor: backgroundColor, textColor: textColor, containedIn: controller, then: then)
            }, onSkip: {
                self.removeCover()
                self.old.removeAll()
                tours.removeAll()
                return then()
            })
        }
    }

    func show(element: TourObject, containedIn controller: UIViewController, hasNext: Bool, backgroundColor: UIColor, textColor: UIColor, onBack: @escaping ()->Void, onNext: @escaping ()->Void, onSkip: @escaping ()->Void) {

        self.currentController = controller
        self.removeCover()

        let textColor = textColor
        let bgColor = backgroundColor

        self.cover(layer: element.view, in: controller, with: bgColor.withAlphaComponent(0.2))

        let width: CGFloat = controller.view.frame.width / 1.5
        let height: CGFloat = getEstimatedHeight(for: element, inWidth: width)

        self.popoverVC.modalPresentationStyle = .popover
        self.popoverVC.preferredContentSize = CGSize(width: width, height: height)
        self.popoverVC.view.backgroundColor = self.backgroundColor
        guard let popover = self.popoverVC.popoverPresentationController else {return}
        popover.permittedArrowDirections = .up
        popover.backgroundColor = self.backgroundColor
        popover.sourceView = element.view

//        var xposition: CGFloat = element.view.bounds.minX
        var xposition: CGFloat = element.view.bounds.midX
        var yposition: CGFloat = element.view.bounds.maxY
        // if left cover is less than half of preferred popover width
        if genLeft(for: element.view.layer, relativeTo: controller.view, with: self.backgroundColor).frame.width < width / 2 {
            // center x
            xposition = element.view.bounds.midX
        }
        // if bottom is less then hald of preferred popover height
        if genBotHalf(for: element.view.layer, relativeTo: controller.view, with: self.backgroundColor).frame.height < height / 2 {
            yposition = element.view.bounds.minY
        }
        // Set popover location
        popover.sourceRect = CGRect(x: xposition, y: yposition, width: 0, height: 0)

        controller.present(self.popoverVC, animated: true, completion: {
            self.popoverVC.setup(header: element.header, desc: element.desc, backgroundColor: bgColor, textColor: textColor, hasPrev: !self.old.isEmpty, hasNext: hasNext, onBack: onBack, onNext: onNext, onSkip: onSkip)
        })
    }
    
    func getEstimatedHeight(for element: TourObject, inWidth width: CGFloat) -> CGFloat {
        
        let estimatedContentHeight = element.desc.height(withConstrainedWidth: width, font: Fonts.getPrimary(size: 17)) + element.header.height(withConstrainedWidth: width, font: Fonts.getPrimaryBold(size: 17))
        let iconHeight: CGFloat = 26
        let buttonHeights: CGFloat = 42
        let skipHeight: CGFloat = 35
        let numberOfItemsInStack: CGFloat = 5
        let paddingBetweenStackItems: CGFloat = 16
        let topAndBottomPadding: CGFloat = 36
        
        let totalHeightWithoutPadding = estimatedContentHeight + iconHeight + buttonHeights + skipHeight
        return totalHeightWithoutPadding + (numberOfItemsInStack * paddingBetweenStackItems) + (topAndBottomPadding * 2)
        
    }

    func removeCover() {
        guard let controller = currentController else {return}
        if let top = controller.view.viewWithTag(topTag) {
            top.removeFromSuperview()
        }

        if let bottom = controller.view.viewWithTag(bottomTag) {
            bottom.removeFromSuperview()
        }

        if let left = controller.view.viewWithTag(leftTag) {
            left.removeFromSuperview()
        }

        if let right = controller.view.viewWithTag(rightTag) {
            right.removeFromSuperview()
        }

        if let frame = controller.view.viewWithTag(frameTag) {
            frame.removeFromSuperview()
        }
    }

    func frame(layer: CALayer, relativeTo view: UIView, with color: UIColor) -> UIView {
        let absoluteFrame = layer.convert(layer.bounds, to: view.layer)
        let padding: CGFloat = 10
        let copyView = UIView(frame: CGRect(x: (absoluteFrame.minX - (padding / 2)) , y: (absoluteFrame.minY - (padding / 2)), width: (absoluteFrame.width + padding), height: (absoluteFrame.height + padding)))
        copyView.layer.borderWidth = (padding / 2)
        copyView.layer.cornerRadius = 2
        copyView.layer.borderColor = color.cgColor
        copyView.backgroundColor = .clear
        copyView.tag = frameTag
        return copyView
    }

    func cover(layer: UIView, in controller: UIViewController, with color: UIColor) {
        controller.view.addSubview(self.genTopHalf(for: layer.layer, relativeTo: controller.view, with: color))
        controller.view.addSubview(self.genBotHalf(for: layer.layer, relativeTo: controller.view, with: color))
//        controller.view.addSubview(self.genLeft(for: layer.layer, relativeTo: controller.view, with: color))
//        controller.view.addSubview(self.genRight(for: layer.layer, relativeTo: controller.view, with: color))
        //        controller.view.addSubview(self.frame(layer: layer.layer, relativeTo: controller.view, with: color))
    }

    func genTopHalf(for layer: CALayer, relativeTo view: UIView, with color: UIColor) -> UIView {
        let absoluteFrame = layer.convert(layer.bounds, to: view.layer)
        let top = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: absoluteFrame.minY))
        top.backgroundColor = color
        top.tag = topTag
        return top
    }

    func genBotHalf(for layer: CALayer, relativeTo view: UIView, with color: UIColor) -> UIView {
        let absoluteFrame = layer.convert(layer.bounds, to: view.layer)
        let bottom = UIView(frame: CGRect(x: 0, y: absoluteFrame.maxY, width: view.frame.width, height: (view.frame.height - absoluteFrame.maxY)))
        bottom.backgroundColor = color
        bottom.tag = bottomTag
        return bottom
    }

    func genLeft(for layer: CALayer, relativeTo view: UIView, with color: UIColor) -> UIView {
        let absoluteFrame = layer.convert(layer.bounds, to: view.layer)
        let left = UIView(frame: CGRect(x: 0, y: absoluteFrame.minY, width: absoluteFrame.minX, height: absoluteFrame.height))
        left.backgroundColor = color
        left.tag = leftTag
        return left
    }

    func genRight(for layer: CALayer, relativeTo view: UIView, with color: UIColor) -> UIView {
        let absoluteFrame = layer.convert(layer.bounds, to: view.layer)
        let right = UIView(frame: CGRect(x: absoluteFrame.maxX, y: absoluteFrame.minY, width: (view.frame.width - absoluteFrame.maxX), height: absoluteFrame.height))
        right.backgroundColor = color
        right.tag = rightTag
        return right
    }
}
