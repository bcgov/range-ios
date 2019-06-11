//
//  LoggerWindow.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-01.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
    
    func scrollToTop() {
        for index in 0...numberOfSections - 1 {
            if numberOfSections > 0 && numberOfRows(inSection: index) > 0 {
                scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
                break
            }
            if index == numberOfSections - 1 {
                setContentOffset(.zero, animated: true)
                break
            }
        }
    }
}

enum LoggerWindowConstraints {
    case Width
    case Height
    case Leading
    case Trailing
    case Bottom
}

class LoggerWindow: UIView {
    // MARK: Variables
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0
    private var width: CGFloat = 390
    private var height: CGFloat = 400
    private var heightMultiplier: CGFloat = 0.25
    
    private var contraintsAdded: [LoggerWindowConstraints: NSLayoutConstraint] = [LoggerWindowConstraints: NSLayoutConstraint]()
    
    private var startPosition: CGPoint! //Start position for the gesture transition
    private var originalHeight: CGFloat = 0.0// Initial Height for the UIView
    private var difference: CGFloat = 0.0
    
    var logs: [String] = [String]()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Entry Point
    func initialize() {
        self.tag = Logger.windowTag
        self.backgroundColor = UIColor(hex: "1f2535")
        self.tableView.backgroundColor = UIColor(hex: "262d3f")
        setupTableView()
        beginListeners()
        position {
            self.initGestureRecognizer()
            self.refresh()
        }
    }
    
    func refresh() {
        self.logs = Logger.logs
        self.tableView.reloadData()
        self.tableView.performBatchUpdates({
            self.tableView.beginUpdates()
            self.tableView.scrollToBottomRow()
            self.tableView.endUpdates()
        }) { (done) in
            return
        }
    }
    
    // MARK: Listeners
    private func beginListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: .screenOrientationChanged, object: nil)
    }
    
    /// Reset max height to window height if
    /// orientation change made it move out of window
    ///
    /// - Parameter notification: UIPanGestureRecognizer
    @objc private func orientationChanged(_ notification: Notification) {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let contraint = contraintsAdded[.Height], contraint.constant > window.frame.height {
            contraint.constant = window.frame.height
        }
    }
    
    // MARK: Presentation
    private func present(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        position { return then() }
    }
    
    func remove() {
        self.closingAnimation {
            self.removeFromSuperview()
        }
    }
    
    private func position(then: @escaping ()-> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.alpha = 0
        window.addSubview(self)
        addInitialConstraints()
        activateConstraints(then: {self.openingAnimation {return then()}})
    }
    
    private func addInitialConstraints() {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var minWindowHeight: CGFloat = 0
        if window.frame.width > window.frame.height {
            minWindowHeight = window.frame.height
        } else {
            minWindowHeight = window.frame.width
        }
        let preferredHeight = minWindowHeight / 4.5
        originalHeight = preferredHeight
        let widthContraint = self.widthAnchor.constraint(equalTo: window.widthAnchor)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: preferredHeight)
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        let leadingContraint = self.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        let trailingConstraint = self.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        
        widthContraint.isActive = true
        heightConstraint.isActive = true
        bottomConstraint.isActive = true
        leadingContraint.isActive = true
        trailingConstraint.isActive = true
        
        self.contraintsAdded[.Width] = widthContraint
        self.contraintsAdded[.Height] = heightConstraint
        self.contraintsAdded[.Bottom] = bottomConstraint
        self.contraintsAdded[.Leading] = leadingContraint
        self.contraintsAdded[.Trailing] = trailingConstraint
    }
    
    func setHeightConstraint(to newHeight: CGFloat) {
        if let contraint = contraintsAdded[.Height] {
            contraint.constant = newHeight
            self.originalHeight = newHeight
        }
    }
    
    private func activateConstraints(then: @escaping ()-> Void) {
        var addedConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        var removedConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        for each in contraintsAdded {
            if each.value.isActive == true {
                addedConstraints.append(each.value)
            } else {
                removedConstraints.append(each.value)
            }
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            NSLayoutConstraint.activate(addedConstraints)
            NSLayoutConstraint.deactivate(removedConstraints)
        }) { (done) in
            return then()
        }
    }
    
    private func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }
    
    private func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration(), animations: {
            if let bottomConstraint = self.getBottomConstraint() {
                bottomConstraint.constant = 0 - (self.frame.height)
            }
            self.alpha = self.invisibleAlpha
        }) { (done) in
            then()
        }
    }
    
    func getBottomConstraint() -> NSLayoutConstraint? {
        if let constraint = contraintsAdded[.Bottom] {
            return constraint
        }
        return nil
    }
    
    func initGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startPosition = sender.location(in: self) // the postion at which PanGestue Started
        }
        
        if sender.state == .began || sender.state == .changed {
            _ = sender.translation(in: self)
            sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self)
            let endPosition = sender.location(in: self) // the posiion at which PanGesture Ended
            difference = endPosition.y - startPosition.y
            setHeightConstraint(to: self.frame.height - difference)
        }
        
        if sender.state == .ended || sender.state == .cancelled {
            //Do Something
        }
    }
}

extension LoggerWindow: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        register(cell: "LoggerWindowTableViewCell")
    }
    
    private func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    private func getLoggerWindowTableViewCell(indexPath: IndexPath) -> LoggerWindowTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LoggerWindowTableViewCell", for: indexPath) as! LoggerWindowTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getLoggerWindowTableViewCell(indexPath: indexPath)
        cell.setup(withMessage: "\(indexPath.row)\t\t\(logs[indexPath.row])")
        return cell
    }
}
