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

    init(header: String, desc: String, on view: UIView) {
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

    let backgroundColor = Colors.active.blue
    var currentController: UIViewController?

    var old: [TourObject] = [TourObject]()

    func initialize(with elements: [TourObject], containerIn controller: UIViewController) {
        self.old.removeAll()
        self.show(elements: elements, containedIn: controller)
    }

    func show(elements: [TourObject], containedIn controller: UIViewController) {
        var tours = elements
        guard let current = tours.last else {
            self.removeCover()
            self.popoverVC.dismiss(animated: true)
            self.old.removeAll()
            return
        }

        show(element: current, containedIn: controller,hasNext: (tours.count > 1 ),onBack: {
            self.removeCover()
            if let prev = self.old.popLast() {
                tours.append(prev)
                self.show(elements: tours, containedIn: controller)
            }
        }, onNext: {
            self.removeCover()
            self.old.append(current)
            tours.removeLast()
            self.show(elements: tours, containedIn: controller)
        }, onSkip: {
            self.removeCover()
            self.old.removeAll()
            tours.removeAll()
            return
        })
    }

    func show(element: TourObject, containedIn controller: UIViewController, hasNext: Bool, onBack: @escaping ()->Void, onNext: @escaping ()->Void, onSkip: @escaping ()->Void) {
        self.currentController = controller
        self.removeCover()
        self.cover(layer: element.view.layer, in: controller, with: Colors.active.blue.withAlphaComponent(0.3))

        // Min Height = button height + title Height + icon height + buttom button height + padding between stackview elements + manual padding
        let minHeight: CGFloat = 220
        let width: CGFloat = controller.view.frame.width / 2.0
        let height: CGFloat = element.desc.height(withConstrainedWidth: width, font: Fonts.getPrimary(size: 17)) + element.header.height(withConstrainedWidth: width, font: Fonts.getPrimaryMedium(size: 17)) + minHeight

        self.popoverVC.modalPresentationStyle = .popover
        self.popoverVC.preferredContentSize = CGSize(width: width, height: height)
        self.popoverVC.view.backgroundColor = self.backgroundColor
        guard let popover = self.popoverVC.popoverPresentationController else {return}
        popover.permittedArrowDirections = .any
        popover.backgroundColor = self.backgroundColor
        popover.sourceView = element.view
        popover.sourceRect = CGRect(x: element.view.layer.frame.midX, y: element.view.layer.frame.midY, width: 0, height: 0)
        controller.present(self.popoverVC, animated: true, completion: {
            self.popoverVC.setup(header: element.header, desc: element.desc, hasPrev: !self.old.isEmpty, hasNext: hasNext, onBack: onBack, onNext: onNext, onSkip: onSkip)
        })

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

    }

    func cover(layer: CALayer, in controller: UIViewController, with color: UIColor) {
        controller.view.addSubview(self.genTopHalf(for: layer, relativeTo: controller.view, with: color))
        controller.view.addSubview(self.genBotHalf(for: layer, relativeTo: controller.view, with: color))
        controller.view.addSubview(self.genLeft(for: layer, relativeTo: controller.view, with: color))
        controller.view.addSubview(self.genRight(for: layer, relativeTo: controller.view, with: color))
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
