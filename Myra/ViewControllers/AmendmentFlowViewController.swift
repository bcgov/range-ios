//
//  AmendmentFlowViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-08-27.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
enum AmendmentFlowMode {
    case Create
    case Initial
    case Mandatory
    case Minor
    case FinalReview
}

class AmendmentFlowViewController: UIViewController, Theme {

    // MARK: Constants
    let whiteScreenTag = 101
    let animationDuration: Double = 0.3

    let suggestedWidth = 400
    let suggestedHeight = 360

    // MARK: Variables
    var callBack: ((_ amendment: Amendment?) -> Void)?
    var amendment: Amendment?
    var mode: AmendmentFlowMode = .Minor

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func returnAmendment() {
        if let callBack = self.callBack {
            if let amendment = self.amendment, amendment.canConfirm() {
                return callBack(amendment)
            } else {
                return callBack(nil)
            }
        }
    }
}

// MARK: Presentation
extension AmendmentFlowViewController {
    func display(on parent: UIViewController, mode: AmendmentFlowMode, response: @escaping (_ amendment: Amendment?) -> Void) {
        self.mode = mode
        self.callBack = response
        self.amendment = Amendment()
        self.view.alpha = 0
        parent.addChild(self)
        positionInCenter(view: self.view, in: parent)
        addShadow(layer: self.view.layer)
        parent.view.addSubview(self.view)
        self.didMove(toParent: parent)
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.alpha = 1
        })
        setWhiteScreen(in: parent)
        initCollectionView()
    }

    func positionInCenter(view:UIView, in parentVC: UIViewController) {
        view.frame = CGRect(x: 0, y: 0, width: suggestedWidth, height: suggestedHeight)
        view.center.x = parentVC.view.center.x
        view.center.y = parentVC.view.center.y
    }

    func remove(cancelled: Bool = false) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.alpha = 0
            self.removeWhiteScreen()
        }) { (done) in
            if !cancelled {
                self.returnAmendment()
            }
            self.didMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let parent = parent else {return}
        
        if let whiteScreen = parent.view.viewWithTag(whiteScreenTag) {
            whiteScreen.frame.size = size
        }
        self.view.alpha = 0
        coordinator.animate(alongsideTransition: { _ in
            self.positionInCenter(view: self.view, in: parent)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
}

// MARK: White screen
extension AmendmentFlowViewController {
    func setWhiteScreen(in parentVC: UIViewController) {
        guard let screen = whiteScreen() else {return}
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cancelled(_:)))
        screen.alpha = 0
        parentVC.view.insertSubview(screen, belowSubview: self.view)
        screen.addGestureRecognizer(tap)
        UIView.animate(withDuration: animationDuration, animations: {
            screen.alpha = 1
        })

    }

    func whiteScreen() -> UIView? {
        guard let p = parent else {return nil}
        let view = UIView(frame: CGRect(x: 0, y: 0, width: p.view.frame.width, height: p.view.frame.height))
        view.center.y = p.view.center.y
        view.center.x = p.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.9)
        view.alpha = 1
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let p = parent else {return}
        if let viewWithTag = p.view.viewWithTag(whiteScreenTag) {
            viewWithTag.removeFromSuperview()
        }
    }

    @objc func cancelled(_ sender: UISwipeGestureRecognizer) {
        //        close()
    }
}

extension AmendmentFlowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        let w = self.view.frame.width
        let h = self.view.frame.height
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
