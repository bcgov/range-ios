//
//  TagImageMLextension.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-02.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Cam
import CoreML
import Extended

enum Genders {
    case Male
    case Female
    case Unknown
}

enum LifeForms {
    case Animal
    case Plant
    case Human
    case Unknown
}

enum PlantTypes {
    case DalmatianToadflax
    case SpottedKnapweed
    case CowParsley
    case PonytailPalm
    case Unknown
}

enum AnimalTypes {
    case Cat
    case Cow
    case Dog
    case Unknown
}


extension TagImage {
    func getContent(of image: UIImage) -> String {
        if let buffer = self.buffer(from: image) {
            let kind = self.getLifeForm(image: buffer)
            switch kind {
            case .Animal:
                let animal = self.getAnimalType(image: buffer)
                return "\(animal)"
            case .Plant:
                let plant = self.getPlantType(image: buffer)
                let plantString = "\(plant)"
                return "\(plantString.convertFromCamelCase())"
            case .Human:
//                let gender = self.getGender(image: buffer)
                return "\(kind)"
            case .Unknown:
                return "\(kind)"
            }
        } else {
            return ""
        }
    }

    func getLifeForm(image: CVPixelBuffer) -> LifeForms {
        let lifeForm = LifeForm()
        guard let output = try? lifeForm.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Animal":
            return .Animal
        case "Human":
            return .Human
        case "Plant":
            return .Plant
        default:
            return .Unknown
        }
    }

    func getPlantType(image: CVPixelBuffer) -> PlantTypes {
        let plants = Plant()
        guard let output = try? plants.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "DalmatianToadflax":
            return .DalmatianToadflax
        case "SpottedKnapweed":
            return .SpottedKnapweed
        case "CowParsley":
            return .CowParsley
        case "PonytailPalm":
            return .PonytailPalm
        default:
            return .Unknown
        }
    }

    func getGender(image: CVPixelBuffer) -> Genders {
        let genders = Gender()
        guard let output = try? genders.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Male":
            return .Male
        case "Female":
            return .Female
        default:
            return .Unknown
        }
    }

    func getAnimalType(image: CVPixelBuffer) -> AnimalTypes {
        let animals = Animal()
        guard let output = try? animals.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Cow":
            return .Cow
        case "Cat":
            return .Cat
        case "Dog":
            return .Dog
        default:
            return .Unknown
        }
    }

    func getHighestProb(in probs: [String: Double]) -> Double {
        var highest: Double = 0.0
        for prob in probs where prob.value > highest {
            highest = prob.value
        }
        return highest
    }

    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
