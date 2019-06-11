//
//  FlowModal.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-15.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FlowHelperModel {
    var initiatingFlowStatus: StatusWithFlow
    var isInitial: Bool
    
    var selectedOption: FlowOption?
    var notes: String = ""
    var hasCommunicatedStatusChange: Bool?
    
    var result: FlowResult?
    
    init(initiatingFlowStatus: StatusWithFlow, isInitial: Bool) {
        self.isInitial = isInitial
        self.initiatingFlowStatus = initiatingFlowStatus
    }
}

class FlowResult {
    var status: RUPStatus
    var notes: String
    
    init(status: RUPStatus, notes: String) {
        self.status = status
        self.notes = notes
    }
}

enum FlowPage: Int, CaseIterable {
    case Options
    case Notes
    case Review
    case Confirmation
}

class FlowModal: CustomModal {

    // MARK: Constants
    let suggestedWidth: CGFloat = 600
    let suggestedHeight: CGFloat = 560
    
    // MARK: Variables
    var completion: ((_ result: FlowResult?) -> Void)?
    var model: FlowHelperModel?
    weak var collectionView: UICollectionView?
    
    // MARK: Entry Point
    func initialize(for model: FlowHelperModel, completion: @escaping (_ result: FlowResult?) -> Void) {
        self.model = model
        self.completion = completion
        setFixed(width: suggestedWidth, height: suggestedHeight)
        style()
        present()
        createCollectionView()
    }
    
    // MARK: Style
    func style() {
        self.backgroundColor = UIColor.black
    }
    
    // MARK: Actions for Buttons on pages
    func nextClicked(fromPage current: FlowPage) {
        guard let pages = collectionView else {return}
        
        if let nextPage = FlowPage(rawValue: Int(current.rawValue + 1)) {
            pages.scrollToItem(at: IndexPath(row: nextPage.rawValue, section: 0), at: .left, animated: true)
            
            // If its the confirmation page, show animation then return results.
            if nextPage == .Confirmation, let cv = self.collectionView {
                cv.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let cell = cv.cellForItem(at: IndexPath(row: nextPage.rawValue, section: 0)) as? FlowConfirmationCollectionViewCell {
                        cell.showAnimation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.returnResult()
                        })
                    }
                }
            }
        } else {
            // last page. dismiss
            returnResult()
        }
    }
    
    func previousClicked(fromPage current: FlowPage) {
        guard let pages = collectionView, let nextPage = FlowPage(rawValue: Int(current.rawValue - 1))  else {return}
        
        pages.scrollToItem(at: IndexPath(row: nextPage.rawValue, section: 0), at: .left, animated: true)
    }
    
    func closeClicked() {
        Alert.show(title: "Cancel", message: "Are you sure you want to cancel?", yes: {
            if let completion = self.completion {
                self.remove()
                return completion(nil)
            }
        }) {
            return
        }
    }
    
    func returnResult() {
        guard let model = self.model, let selectedOption = model.selectedOption, let completion = self.completion else {return}
        let newStatus = FlowHelper.shared.translate(option: selectedOption)
        let result = FlowResult(status: newStatus, notes: model.notes)
        completion(result)
        self.remove()
    }
}

// MARK: Collection View
extension FlowModal: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func createCollectionView() {
        // Create
        let collectionView: UICollectionView = UICollectionView(frame: self.frame, collectionViewLayout: getCollectionViewLayout())
        
        // Set alpha to zero so we can animate the presentation
        collectionView.alpha = 0
        
        // Add
        self.addSubview(collectionView)
        
        // Constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthContraint = collectionView.widthAnchor.constraint(equalToConstant: self.frame.width)
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: self.frame.height)
        let centerXContraint = collectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let centerYConstraint = collectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        
        widthContraint.isActive = true
        heightConstraint.isActive = true
        centerXContraint.isActive = true
        centerYConstraint.isActive = true
        
        NSLayoutConstraint.activate([widthContraint, heightConstraint, centerXContraint, centerYConstraint])
        
        // set reference
        self.collectionView = collectionView
        
        // normal collection view iniialization
        self.initCollectionView()
        
        // animate presentation (by presentation i mean alpha change)
        UIView.animate(withDuration: SettingsManager.shared.getAnimationDuration()) {
            collectionView.alpha = 1
        }
    }
    
    func initCollectionView() {
        guard let collectionView = self.collectionView else {return}
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCell(name: "FlowOptionsCollectionViewCell")
        registerCell(name: "FlowNotesCollectionViewCell")
        registerCell(name: "FlowReviewCollectionViewCell")
        registerCell(name: "FlowConfirmationCollectionViewCell")
        
        // For some reason the second last line in the getCollectionViewLayout() function is not doing it....
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.isScrollEnabled = false
        collectionView.isPagingEnabled = true
    }
    
    func getCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func cellSize() -> CGSize {
        let w = (self.frame.width)
        let h = (self.frame.height)
        return CGSize(width: w, height: h)
    }
    
    func registerCell(name: String) {
        guard let collectionView = self.collectionView else {return}
        collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func getOptionsPage(indexPath: IndexPath) -> FlowOptionsCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FlowOptionsCollectionViewCell", for: indexPath) as! FlowOptionsCollectionViewCell
    }
    
    func getNotesPage(indexPath: IndexPath) -> FlowNotesCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FlowNotesCollectionViewCell", for: indexPath) as! FlowNotesCollectionViewCell
    }
    
    func getReviewPage(indexPath: IndexPath) -> FlowReviewCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FlowReviewCollectionViewCell", for: indexPath) as! FlowReviewCollectionViewCell
    }
    
    func getConfirmationPage(indexPath: IndexPath) -> FlowConfirmationCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FlowConfirmationCollectionViewCell", for: indexPath) as! FlowConfirmationCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellType = FlowPage(rawValue: Int(indexPath.row)), let model = self.model else {return UICollectionViewCell()}
        var cell = FlowCell()
        switch cellType {
        case .Options:
            cell = getOptionsPage(indexPath: indexPath)
        case .Notes:
            cell = getNotesPage(indexPath: indexPath)
        case .Review:
            cell = getReviewPage(indexPath: indexPath)
        case .Confirmation:
            cell = getConfirmationPage(indexPath: indexPath)
        }
        
        cell.initialize(for: model, nextClicked: {
            self.nextClicked(fromPage: cellType)
        }, previousClicked: {
            self.previousClicked(fromPage: cellType)
        }) {
            self.closeClicked()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FlowPage.allCases.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
    
    func gotoPage(row: Int) {
        guard let collectionView = self.collectionView else {return}
        let indexPath: IndexPath = IndexPath(row: row, section: 0)
        collectionView.reloadItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
