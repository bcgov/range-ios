//
//  AmendmentFlow.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-14.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

enum AmendmentFlowMode {
    case Create
    case Initial
    case Mandatory
    case Minor
    case FinalReview
}

class AmendmentFlow: CustomModal {
    // MARK: Constants
    let whiteScreenTag = 101
    let suggestedWidth = 400
    let suggestedHeight = 360
    
    // MARK: Variables
    var callBack: ((_ amendment: Amendment?) -> Void)?
    var amendment: Amendment?
    var mode: AmendmentFlowMode = .Minor
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    func initialize(mode: AmendmentFlowMode, response: @escaping (_ amendment: Amendment?) -> Void) {
        self.mode = mode
        setFixed(width: 400, height: 360)
        self.callBack = response
        self.amendment = Amendment()
        self.initCollectionView()
        style()
        present()
    }
    
    func returnAmendment() {
        if let callBack = self.callBack {
            if let amendment = self.amendment, amendment.canConfirm() {
                callBack(amendment)
            } else {
                callBack(nil)
            }
            remove()
        }
    }
    
    func style() {
        styleModalBox()
    }
}

extension AmendmentFlow: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func initCollectionView() {
        setCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCell(name: "AmendmentPageOneCollectionViewCell")
        registerCell(name: "AmendmentPageTwoCollectionViewCell")
        registerCell(name: "AmendmentPageThreeCollectionViewCell")
        registerCell(name: "AmendmentPageFinalCollectionViewCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        //        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
    
    func cellSize() -> CGSize {
        let w = (self.frame.width)
        let h = (self.frame.height)
        return CGSize(width: w, height: h)
    }
    
    func registerCell(name: String) {
        collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func getPageOne(indexPath: IndexPath) -> AmendmentPageOneCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AmendmentPageOneCollectionViewCell", for: indexPath) as! AmendmentPageOneCollectionViewCell
    }
    
    func getPageTwo(indexPath: IndexPath) -> AmendmentPageTwoCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AmendmentPageTwoCollectionViewCell", for: indexPath) as! AmendmentPageTwoCollectionViewCell
    }
    
    func getPageThree(indexPath: IndexPath) -> AmendmentPageThreeCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AmendmentPageThreeCollectionViewCell", for: indexPath) as! AmendmentPageThreeCollectionViewCell
    }
    
    func getPageFinal(indexPath: IndexPath) -> AmendmentPageFinalCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AmendmentPageFinalCollectionViewCell", for: indexPath) as! AmendmentPageFinalCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let amendment = self.amendment else {return getPageOne(indexPath: indexPath)}
        switch indexPath.row {
        case 0:
            let cell = getPageOne(indexPath: indexPath)
            cell.setup(amendment: amendment, mode: mode, parent: self)
            return cell
        case 1:
            let cell = getPageTwo(indexPath: indexPath)
            cell.setup(amendment: amendment, mode: mode, parent: self)
            return cell
        case 2:
            let cell = getPageThree(indexPath: indexPath)
            cell.setup(amendment: amendment, mode: mode, parent: self)
            return cell
        default:
            return getPageOne(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.amendment != nil {
            return 3
        } else {
            return 0
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
    
    func gotoPage(row: Int) {
        let indexPath: IndexPath = IndexPath(row: row, section: 0)
        self.collectionView.reloadItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
