//
//  Pin.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import MapKit

public class Pin: MKAnnotationView, Theme {

    let width: CGFloat = 100
    let height: CGFloat = 100

    var photo: RangePhoto?

    @IBOutlet weak var imageView: UIImageView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    func set(photo: RangePhoto, width: CGFloat? = nil, height:CGFloat? = nil) {
        self.frame.size.width = width ?? self.width
        self.frame.size.height = height ?? self.height
        self.photo = photo
        if let image = photo.getImage() {
            imageView.image = image
        }
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(photo.trueHeading * .pi/180))
    }

    public func setSize( width: CGFloat, height: CGFloat){
        self.frame.size.width = width
        self.frame.size.height = height
    }

    func style() {
        self.frame.size.width = width
        self.frame.size.height = height
        imageView.frame.size.height = height
        imageView.frame.size.width = width
//        makeCircle(view: self)
//        makeCircle(imageView: imageView)
        imageView.clipsToBounds = true
    }
    
    func makeCircle(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.clipsToBounds = true
    }
}
