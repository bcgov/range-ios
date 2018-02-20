//
//  BaseViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var loading: UIImageView?
    var loadingImages = [UIImage]()


    override func viewDidLoad() {
        super.viewDidLoad()
        if loadingImages.count != 4 {
            setupLoadingIndicatorImages()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Loading Spinner
extension BaseViewController {
    func setupLoadingIndicatorImages() {
        var images = [UIImage]()

        for i in 0...3 {
            images.append(UIImage(named: "cow\(i)")!)
        }
        loadingImages = images
    }

    func getIoadingView() -> UIImageView {
        let view = UIImageView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 100, height: 100))
        view.animationImages = loadingImages
        view.animationDuration = 0.3
        view.center.y = self.view.center.y
        view.center.x = self.view.center.x
        view.alpha = 1
        return view
    }

    // TODO: currently unused. reposition loading spinner.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            if UIDevice.current.orientation.isLandscape{
                print("Landscape")
            } else {
                print("Portrait")
            }
        }
    }
}

// Styles
extension BaseViewController {
    func addShadow(layer: CALayer) {
        layer.borderColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
    }

    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }
}
