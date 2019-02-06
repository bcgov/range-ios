//
//  Feedback.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class Feedback: NSObject {
    
    // MARK: Variables
    private static let buttonTag = 666881
    
    private static let padding: CGFloat = 5
    private static let width: CGFloat = 100
    private static let height: CGFloat = 100
    
    private static var viewFeedbacks: ViewFeedbacksViewController = {
        return UIStoryboard(name: "ViewFeedbacks", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewFeedbacks") as! ViewFeedbacksViewController
    }()
    
    // MARK: Entry Point
    public static func initializeButton() {
        // Dont continue if app is offline
        guard let r = Reachability() else {return}
        if r.connection == .none {
            return
        }
        
        // Animations for presentation of screens take a bit of time,
        // So let's delay the presentation of the button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            // you may have lost connection is 0.5 seconds
            if r.connection == .none {
                return
            }
            
            // Good, lets display or move the icon if its already displayed
            self.displayButton()
        }
    }
    
    // MARK: Presentation
    
    /// Display feedback button
    /// If feedback button is already presented,
    /// make sure it is in front of all other subviews
    /// except for logger window (if presented)
    private static func displayButton() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if window.viewWithTag(buttonTag) != nil {
            // if already presented
            bringButtonToFront()
        } else if let button = createButtonView() {
            window.addSubview(button)
            addGestureRecognizerToButton()
            beginListeners()
        }
    }
    
    // MARK: Listeners
    private static func beginListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: .screenOrientationChanged, object: nil)
    }
    
    /// Reset positioning of button if
    /// orientation change made it move out of window
    ///
    /// - Parameter notification: UIPanGestureRecognizer
    @objc private static func orientationChanged(_ notification:Notification) {
        resetButtonPositionIfOutOfFrame()
    }
    
    // MARK: Presentation
    
    /// Move feedback button in front of other subviews
    /// but behind logger window
    private static func bringButtonToFront() {
        guard let window = UIApplication.shared.keyWindow, let button = window.viewWithTag(buttonTag) else {return}
        window.bringSubviewToFront(button)
        resetButtonPositionIfOutOfFrame()
        // Bring to front but behind Logger window if its presented
        if let logger = window.viewWithTag(Logger.windowTag) {
            window.bringSubviewToFront(logger)
        }
    }
    
    /// Set buttons frame to the default frame
    private static func resetButtonPositionIfOutOfFrame() {
        guard let button = getButton(), let window = UIApplication.shared.keyWindow, let baseFrame = getBaseButtonFrame(), !button.frame.intersects(window.frame) else {return}
        button.frame = baseFrame
    }
    
    private static func getBaseButtonFrame() -> CGRect? {
        guard let window = UIApplication.shared.keyWindow else {
            return nil
        }
        return CGRect(x: padding, y: ((window.frame.maxY - height) - padding), width: width, height: height)
    }
    
    /// Create a UIButton for feedback
    ///
    /// - Returns: Feedback Button View
    private static func createButtonView() -> UIView? {
        guard let frame =  getBaseButtonFrame() else {
            return nil
        }
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "button_feedback"), for: .normal)
        button.addTarget(self, action: #selector(Feedback.buttonAction), for: .touchUpInside)
        button.tag = buttonTag
        return button
    }
    
    /// Get feeback button view if exists
    ///
    /// - Returns: Feedback Button
    private static func getButton() -> UIView? {
        if let window = UIApplication.shared.keyWindow, let viewWithTag = window.viewWithTag(buttonTag) {
            return viewWithTag
        } else {
            return nil
        }
    }
    
    /// Remove feedback button from window
    public static func removeButton() {
        if let current = getButton() {
            current.removeFromSuperview()
        }
    }
    
    // MARK: Gesture recognition
    /// Add pan gesture recognizer to button
    private static func addGestureRecognizerToButton() {
        guard let button = getButton() else {return}
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        button.addGestureRecognizer(gestureRecognizer)
    }
    
    
    /// Move button to new position on drag
    ///
    /// - Parameter gestureRecognizer: UIPanGestureRecognizer
    @objc private static func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else {return}
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed, let recognizedView = gestureRecognizer.view {
            let translation = gestureRecognizer.translation(in: window)
            let centerX = recognizedView.center.x + translation.x
            let centerY = recognizedView.center.y + translation.y
            recognizedView.center = CGPoint(x: centerX, y: centerY)
            gestureRecognizer.setTranslation(CGPoint.zero, in: window)
        }
        
        if gestureRecognizer.state == .ended {
        }
    }
    
    // MARK: Event Handlers
    @objc private static func buttonAction() {
        let view: FeedbackView = UIView.fromNib()
        removeButton()
        view.initialize()
    }
    
    // MARK: Utilities
    
    /// Called from FeedbackView, but could be used from anywhere else
    ///
    /// - Parameters:
    ///   - feedback: Feedback object
    ///   - completion: Callback
    public static func send(feedback: FeedbackElement, completion: @escaping (_ success: Bool)->Void) {
        guard let endpoint = URL(string: Constants.API.feedbackPath, relativeTo: Constants.API.baseURL) else {
            return completion(false)
        }
        
        API.post(endpoint: endpoint, params: feedback.toDictionary()) { (response) in
            return completion(true)
        }
    }
    
    
    /// Present Submitted feedbacks
    ///
    /// - Parameter vc: ViewController to present in
    public static func showFeedbacks(in vc: UIViewController) {
        vc.present(viewFeedbacks, animated: true)
    }
}
