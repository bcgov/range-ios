//
//  ImportCriteria.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ImportCriteria: UIView, Theme {

    // MARK: Variables
    private var plan: RUP?
    var object: ImportCriteriaObject?

    private let padding: CGFloat = 25
    private let width: CGFloat = 390
    private let height: CGFloat = 400
    private let animationDuration = 0.5
    private let visibleAlpha: CGFloat = 1
    private let invisibleAlpha: CGFloat = 0

    var callBack: ((_ plantCommunity: PlantCommunity,_ sections: [PlantCommunityCriteriaFromSection])-> Void)?

    // White screen
    private let whiteScreenTag: Int = 9535
    private let whiteScreenAlpha: CGFloat = 0.9

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var backButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var mainButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!


    @IBAction func backAction(_ sender: Any) {
        let visible = collectionView.indexPathsForVisibleItems
        guard let current = visible.first, current.row > 0 else {return}

        collectionView.scrollToItem(at: IndexPath(row: (current.row - 1), section: 0), at: .centeredHorizontally, animated: true)

        switch current.row - 1 {
        case 0:
            styleForPastureSection()
        case 1:
            styleForPCSection()
        case 2:
            styleForCriteriaSection()
        default:
            return
        }
    }
    
    @IBAction func mainButtonAction(_ sender: Any) {
        guard let callback = self.callBack, let object = self.object else {return}
        if object.selectedSections().isEmpty {
            Alert.show(title: "Invalid import", message: "Please select at least one criteria to import")
        } else {
            guard let pc = object.plantCommunity else {return}
            // Callback array of objects
            var alertMsgSections = ""
            if object.RangeReadiness {
                alertMsgSections = "\(alertMsgSections)Range-Readiness\n"
            }
            if object.ShrubUse {
                alertMsgSections = "\(alertMsgSections)Shurub-Use\n"
            }
            if object.StubbleHeight {
                alertMsgSections = "\(alertMsgSections)Stubble-Height\n"
            }
            Alert.show(title: "Override specified crietia?", message: "The following Criteria sections in the current plant will be overriden:\n\(alertMsgSections)", yes: {
                callback(pc, object.selectedSections())
                self.closingAnimation {
                    self.removeWhiteScreen()
                    self.removeFromSuperview()
                }
            }) {}

        }
    }

    @IBAction func cancelAction(_ sender: Any) {
//         guard let callback = self.callBack else {return}
        closingAnimation {
            self.removeWhiteScreen()
            self.removeFromSuperview()
        }
    }

    
    // MARK: Entry Point
    func showFlow(for plan: RUP, then: @escaping(_ plantCommunity: PlantCommunity,_ sections: [PlantCommunityCriteriaFromSection]) -> Void) {
        initCollectionView()
        style()
        self.plan = plan
        object = ImportCriteriaObject(for: plan)
        self.callBack = then
        self.position {
            self.collectionView.reloadData()
        }

    }

    // MARK: Positioning/ displaying / Removing
    func remove() {
        self.closingAnimation {
            self.removeWhiteScreen()
            self.removeFromSuperview()
        }
    }

    func position(then: @escaping ()-> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}

        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.alpha = 0
        window.addSubview(self)
        addConstraints()

        showWhiteBG(then: {
            self.openingAnimation {
                return then()
            }
        })
    }

    func addConstraints() {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: height),
            self.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            ])
    }

    // MARK: Displaying animations
    func openingAnimation(then: @escaping ()-> Void) {
        self.alpha = invisibleAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.visibleAlpha
        }) { (done) in
            then()
        }
    }

    func closingAnimation(then: @escaping ()-> Void) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = self.invisibleAlpha
        }) { (done) in
            then()
        }
    }

    // MARK: White Screen
    func showWhiteBG(then: @escaping()-> Void) {
        guard let window = UIApplication.shared.keyWindow, let bg = whiteScreen() else {return}

        bg.alpha = invisibleAlpha
        window.insertSubview(bg, belowSubview: self)
        bg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.centerXAnchor.constraint(equalTo:  window.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo:  window.centerYAnchor),
            bg.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            bg.topAnchor.constraint(equalTo: window.topAnchor),
            bg.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

        UIView.animate(withDuration: animationDuration, animations: {
            bg.alpha = self.visibleAlpha
        }) { (done) in
            return then()
        }

    }

    func whiteScreen() -> UIView? {
        guard let window = UIApplication.shared.keyWindow else {return nil}

        let view = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height))
        view.center.y = window.center.y
        view.center.x = window.center.x
        view.backgroundColor = Colors.active.blue.withAlphaComponent(0.2)
        view.alpha = visibleAlpha
        view.tag = whiteScreenTag
        return view
    }

    func removeWhiteScreen() {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let viewWithTag = window.viewWithTag(whiteScreenTag) {
            UIView.animate(withDuration: animationDuration, animations: {
                viewWithTag.alpha = self.invisibleAlpha
            }) { (done) in
                viewWithTag.removeFromSuperview()
            }
        }
    }

    // MARK: Showing pages
    // (Cells)

    func showChoosePasture() {
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        styleForPastureSection()
    }

    func showChoosePlantCommunity() {
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        styleForPCSection()
    }

    func showChooseCriteria() {
        let indexPath: IndexPath = IndexPath(row: 2, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        styleForCriteriaSection()
    }

    // MARK: Styles
    func style() {
        sectionTitle.font = Fonts.getPrimaryBold(size: 22)
        sectionTitle.textColor = Colors.active.blue
        cancelButton.setTitleColor(Colors.active.blue, for: .normal)
        styleFillButton(button: mainButton)
        styleContainer(view: self)
        styleForPastureSection()
    }

    func styleForPastureSection() {
        sectionTitle.text = "Choose Pasture"
        self.backButton.alpha = 0
        self.mainButton.alpha = 0
    }

    func styleForPCSection() {
        sectionTitle.text = "Choose Plant Community"
        self.backButton.alpha = 1
        self.mainButton.alpha = 0
    }

    func styleForCriteriaSection() {
        sectionTitle.text = "Choose Criteria"
        mainButton.setTitle("Import", for: .normal)
        self.backButton.alpha = 1
        self.mainButton.alpha = 1
    }

    func backButton(show: Bool) {
        let animation = UIViewPropertyAnimator.init(duration: 1, dampingRatio: 0.8) {
            if show {
                self.backButtonLeading.constant = 0 - (self.backButton.frame.width + self.padding)
                self.backButton.alpha = 0
                self.layoutIfNeeded()
            } else {
                self.backButtonLeading.constant = self.padding
                self.backButton.alpha = 1
                self.layoutIfNeeded()
            }
        }
        animation.startAnimation()
    }

    func mainButton(show: Bool) {
        let animation = UIViewPropertyAnimator.init(duration: 1, dampingRatio: 0.8) {
            if show {
                self.mainButtonBottom.constant = 0 - (self.mainButton.frame.height + self.padding)
                self.mainButton.alpha = 0
                self.layoutIfNeeded()
            } else {
                self.mainButtonBottom.constant = self.padding
                self.mainButton.alpha = 1
                self.layoutIfNeeded()
            }
        }
        animation.startAnimation()
    }

}


extension ImportCriteria: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func initCollectionView() {
        registerCell(name: "ChoosePastureCollectionViewCell")
        setCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
    }

    func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }

    func registerCell(name: String) {
        collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }

    func getChoosePastureCell(indexPath: IndexPath) -> ChoosePastureCollectionViewCell {
    return collectionView.dequeueReusableCell(withReuseIdentifier: "ChoosePastureCollectionViewCell", for: indexPath) as! ChoosePastureCollectionViewCell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width), height: (self.collectionView.frame.height))
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let object = self.object else {
            return getChoosePastureCell(indexPath: indexPath)
        }

        let cell = getChoosePastureCell(indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.setup(for: object, type: .Pastures, parent: self)
            return cell
        case 1:
            cell.setup(for: object, type: .PlantCommunities, parent: self)
            return cell
        case 2:
            cell.setup(for: object, type: .Criteria, parent: self)
            return cell
        default:
            return cell
        }
    }
}
