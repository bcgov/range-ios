//
//  ImportCriteria.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-13.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ImportCriteria: CustomModal {

    // MARK: Variables
    private var plan: Plan?
    var object: ImportCriteriaObject?

    private let padding: CGFloat = 25
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

    // MARK: Outlet Actions
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
        remove()
    }
    
    // MARK: Entry Point
    func initialize(for plan: Plan, then: @escaping(_ plantCommunity: PlantCommunity,_ sections: [PlantCommunityCriteriaFromSection]) -> Void) {
        self.callBack = then
        self.plan = plan
        object = ImportCriteriaObject(for: plan)
        setFixed(width: 390, height: 400)
        initCollectionView()
        style()
        present()
    }

    // MARK: Showing pages
    // (Cells)

    func showChoosePasture() {
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.collectionView.reloadItems(at: [indexPath])
        styleForPastureSection()
    }

    func showChoosePlantCommunity() {
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.collectionView.reloadItems(at: [indexPath])
        styleForPCSection()
    }

    func showChooseCriteria() {
        let indexPath: IndexPath = IndexPath(row: 2, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.collectionView.reloadItems(at: [indexPath])
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
        let animation = UIViewPropertyAnimator.init(duration: (SettingsManager.shared.getAnimationDuration() * 2), dampingRatio: CGFloat(SettingsManager.shared.getAnimationDuration())) {
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
        let animation = UIViewPropertyAnimator.init(duration: (SettingsManager.shared.getAnimationDuration() * 2), dampingRatio: CGFloat(SettingsManager.shared.getAnimationDuration())) {
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
