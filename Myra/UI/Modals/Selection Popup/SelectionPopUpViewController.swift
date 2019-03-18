//
//  SelectionPopUpViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-15.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class SelectionPopUpViewController: UIViewController, Theme {

    // MARK: Constants
    let cellHeight: CGFloat = 33
    let buttonHeightConstant: CGFloat = 42
    let headerHeightConstant: CGFloat = 35
    
    // MARK: Variables
    var parentVC: BaseViewController?
    var objects: [SelectionPopUpObject] = [SelectionPopUpObject]()
    var completion: ((_ done: Bool,_ result: SelectionPopUpObject?) -> Void )?
    var multiCompletion: ((_ done: Bool,_ result: [SelectionPopUpObject]?) -> Void )?
    var liveMultiCompletion: ((_ result: [SelectionPopUpObject]?) -> Void )?
    var multiSelect: Bool = false
    var liveMultiSelect: Bool = false
    var selectedIndexes: [Int] = [Int]()

    var headerTxt: String = ""

    var otherText: String = ""
    var otherEnabled: Bool = true

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!

    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        style()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        if let callback = completion {
            return callback(false, nil)
        }
    }

    @IBAction func selectAction(_ sender: UIButton) {
        sendBack()
    }

    func sendBack() {
        var selected = [SelectionPopUpObject]()
        for i in selectedIndexes {
            if objects[i].display.lowercased() == "other", !otherText.isEmpty {
                selected.append(SelectionPopUpObject(display: otherText))
            } else {
                 selected.append(objects[i])
            }
        }
        if multiSelect, let callback = multiCompletion {
            return callback(true, selected)
        } else if liveMultiSelect, let liveCallBack = liveMultiCompletion {
            liveCallBack(selected)
        }
    }

    // MARK: Functions
    // MARK: Setup
    func setupSimple(header: String? = "", objects: [SelectionPopUpObject], completion: @escaping (_ done: Bool,_ result: SelectionPopUpObject?) -> Void) {
        self.completion = completion
        self.objects = objects
        self.headerTxt = header ?? ""
        setupTable()
    }

    func setup(header: String? = "", objects: [SelectionPopUpObject], onVC: BaseViewController, onButton: UIButton? = nil, onLayer: CALayer? = nil, inView: UIView? = nil, otherEnabled: Bool? = true ,completion: @escaping (_ done: Bool,_ result: SelectionPopUpObject?) -> Void) {
        self.completion = completion
        self.objects = objects
        self.headerTxt = header ?? ""
        self.parentVC = onVC
        setupTable()
        if let button = onButton {
            display(on: button)
        } else if let layer = onLayer, let container = inView {
            display(on: layer, in: container)
        }

        if let enabledOther = otherEnabled, !enabledOther {
            self.otherEnabled = enabledOther
        }

    }

    func display(on layer: CALayer, in view: UIView) {
        guard let parent = self.parentVC else {
            return
        }
        parent.showPopUp(vc: self, on: layer, inView: view)
    }

    func display(on: UIButton) {
        guard let parent = self.parentVC else {
            return
        }
        parent.showPopOver(on: on, vc: self, height: getEstimatedHeight(), width: getEstimatedWidth(), arrowColor: nil)
//        parent.showPopUp(vc: self, on: on)
    }

    func setupMulti(header: String? = "", selected: [SelectionPopUpObject],objects: [SelectionPopUpObject], completion: @escaping (_ done: Bool,_ result: [SelectionPopUpObject]?) -> Void) {
        self.multiSelect = true
        self.multiCompletion = completion
        self.objects = objects

        // find already selected indexes
        for (index,element) in objects.enumerated() {
            for item in selected where element.value == item.value {
                selectedIndexes.append(index)
            }
        }
        self.headerTxt = header ?? ""
        setupTable()
    }

    func setupLive(header: String? = "",onVC: BaseViewController, onButton: UIButton, selected: [SelectionPopUpObject],objects: [SelectionPopUpObject], completion: @escaping (_ result: [SelectionPopUpObject]?) -> Void) {
        self.liveMultiSelect = true
        self.liveMultiCompletion = completion
        self.objects = objects

        // find already selected indexes
        for (index,element) in objects.enumerated() {
            for item in selected where element.value == item.value {
                selectedIndexes.append(index)
            }
        }
        self.headerTxt = header ?? ""
        setupTable()
        self.parentVC = onVC
        onVC.showPopUp(vc: self, on: onButton)
    }

    func getEstimatedHeight() -> Int {
        // top and bottom padding in cell
        let padding = 20
        if objects.count == 0 {return padding}
        var total = (objects.count * Int(cellHeight)) + (objects.count * padding)
        if multiSelect {
            // add button height
            total += Int(buttonHeightConstant)
        }
        if liveMultiSelect {
            // add header height
            total += Int(headerHeightConstant)
        }
        return total
    }

    func getEstimatedWidth() -> Int {
        var max: CGFloat = 0
        if headerTxt.count > 0 {
              max = headerTxt.width(withConstrainedHeight: headerHeightConstant, font: defaultSectionSubHeaderFont())
        }
        for element in objects {
            let w = element.display.width(withConstrainedHeight: cellHeight, font: Fonts.getPrimary(size: 17))
            if w > max {
                max = w
            }
        }
        // 20 is the leading + trailing of cell
        var padding: CGFloat = 20.0
        if liveMultiSelect {
            padding += 32.0
        }
        return Int((max + padding))
    }

    func canDisplayFullContentIn(height: Int) -> Bool {
        return getEstimatedHeight() <= height
    }

    // MARK: Style
    func style() {
        guard let btnHeight = selectButtonHeight else {return}
        if multiSelect {
            btnHeight.constant = buttonHeightConstant
            styleFillButton(button: selectButton)
        } else {
            btnHeight.constant = 0
            selectButton.alpha = 0
        }
        if headerTxt.count > 0 {
            self.header.text = headerTxt
            styleSubHeader(label: header)
            headerHeight.constant = headerHeightConstant
        } else {
            headerHeight.constant = 0
        }
    }
}

// MARK: TableView
extension SelectionPopUpViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "selectionPopUpTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> selectionPopUpTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "selectionPopUpTableViewCell", for: indexPath) as! selectionPopUpTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var color = Colors.oddCell
        if indexPath.row % 2 == 0 {
            color = Colors.evenCell
        }
        let cell = getCell(indexPath: indexPath)
        cell.setup(object: objects[indexPath.row], bg: color)
        // if element should be selected
        if multiSelect || liveMultiSelect {
            if selectedIndexes.contains(indexPath.row) {
                cell.select()
            } else {
                cell.deSelect()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if multi select is not enabled, return selection

        if !multiSelect && !liveMultiSelect {
            guard let callback = completion else {return}
            if objects[indexPath.row].display.lowercased() == "other", otherEnabled {
                // Prompt input
                let inputModal: InputModal = UIView.fromNib()
                inputModal.initialize(header: "Other") { (name) in
                    if name != "" {
                        return callback(true, SelectionPopUpObject(display: name))
                    }
                }
            } else {
                self.dismiss(animated: true) {
                    return callback(true, self.objects[indexPath.row])
                }
            }
        } else {
            // if is already selected
            if selectedIndexes.contains(indexPath.row) {
                // deselect
                guard let index = selectedIndexes.index(of: indexPath.row) else {return}
                selectedIndexes.remove(at: index)
            } else {

                if objects[indexPath.row].display.lowercased() != "other", otherEnabled {
                    // select
                    selectedIndexes.append(indexPath.row)
                } else {
                    showOtherOption { (customText) in
                        if !customText.isEmpty {
                            self.otherText = customText
                            self.selectedIndexes.append(indexPath.row)
                            if self.liveMultiSelect {
                                self.sendBack()
                            }
                        } else {
                            self.otherText = ""
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }

        if liveMultiSelect {
            sendBack()
        }
    }

    func showOtherOption(completion: @escaping(_ text: String) -> Void) {
        // Prompt input
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Other") { (name) in
            return completion(name)
        }
    }

}
