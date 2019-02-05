//
//  FormMenu.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-02-04.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import UIKit

class FormMenu: UIView, Theme {
    
    // MARK: Variables
    var selectedSection: FromSection = .BasicInfo
    var parentTable: UITableView?
    var container: UIView?
    var containerWidth: NSLayoutConstraint!
    var isExpanded = true
    
    let landscapeMenuWidh: CGFloat = 265
    let portraitMenuWidth: CGFloat = 64
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Entry Point
    func initialize(inView container: UIView, containerWidth: NSLayoutConstraint, parentTable: UITableView) {
        self.containerWidth = containerWidth
        self.container = container
        self.parentTable = parentTable
        self.style(in: container)
        self.setupTableView()
        self.frame = container.frame
        container.addSubview(self)
        addContraints(relativeTo: container)
    }
    
    func setMenu(expanded: Bool) {
        guard let containerWidth = self.containerWidth else {return}
        
        if expanded {
            containerWidth.constant = landscapeMenuWidh
        } else {
            containerWidth.constant = portraitMenuWidth
        }
        
        self.tableView.reloadData()
        
    }
    
    func setContainerWidth(to newWidth: CGFloat) {
        guard let containerWidth = self.containerWidth else {return}
        containerWidth.constant = newWidth
    }
    
    // MARK: Menu Selection
    // from form change to menu
    func select(section: FromSection) {
        if section == selectedSection {return}
        let prevIndexPath = IndexPath(row: selectedSection.rawValue, section: 0)
        let newIndexPath = IndexPath(row: section.rawValue, section: 0)
        self.selectedSection = section
        self.tableView.reloadRows(at: [prevIndexPath, newIndexPath], with: .automatic)
        self.scrollToRowIfNotVisible(at: newIndexPath)
        /*
        self.tableView.performBatchUpdates({
            self.tableView.reloadRows(at: [prevIndexPath, newIndexPath], with: .automatic)
//            if section.rawValue > FromSection.allCases.count / 2 {
//                self.tableView.scrollToBottomRow()
//            } else {
//                self.tableView.scrollToTop()
//            }
        }) { (done) in
            self.scrollToRowIfNotVisible(at: newIndexPath)
            Logger.log(message: "Form section: \(section)")
        }*/
    }
    
    func scrollToRowIfNotVisible(at indexPath: IndexPath) {
        guard let visibles = self.tableView.indexPathsForVisibleRows else {return}
        
        if !visibles.contains(indexPath) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // from menu change to form
    func scrollToForm(section: FromSection) {
        guard let parentTable = self.parentTable else {
            Logger.log(message: "Menu View could not find reference to form table")
            return
        }
        let indexPath = IndexPath(row: section.rawValue, section: 0)
        parentTable.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // find current module visible in form that should be highlighted in menu
    func highlightAppropriateMenuItem() {
        guard let parentTable = parentTable, let indexPaths = parentTable.indexPathsForVisibleRows, indexPaths.count > 0 else {
            Logger.log(message: "Menu View could not find reference to form table, or parent table does not have visible rows")
            return
        }
        
        // select the first indexPath
        var indexPath = indexPaths[0]
        
        // If there are 3 or more visible cells, pick the middle
        if indexPaths.count > 1 {
            let count = indexPaths.count
            indexPath = indexPaths[count/2]
        }
        
        // if there are 2 visible cells, find the most visible
        if indexPaths.count == 2 {
            let visibleRect = CGRect(origin: parentTable.contentOffset, size: parentTable.bounds.size)
            let visiblePoint = CGPoint(x:visibleRect.midX, y:visibleRect.midY)
            if let i = parentTable.indexPathForRow(at: visiblePoint) {
                indexPath = i
            }
        }
        
        if let section = FromSection.init(rawValue: indexPath.row) {
            self.select(section: section)
        }
            
    }
    
    // MARK: Styles
    func style(in container: UIView) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        container.layer.cornerRadius = 5
        self.addShadow(to: container.layer, opacity: 0.8, height: 2)
    }
    
    // MARK: Constraints
    func addContraints(relativeTo container: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
    }
}
extension FormMenu: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        register(cell: "FormMenuItemTableViewCell")
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getMenuItemCell(indexPath: IndexPath) -> FormMenuItemTableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "FormMenuItemTableViewCell", for: indexPath) as! FormMenuItemTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // We do not use menu buttons for 3 Basic information sub-sections:
        // Plan Info
        // Agreement Info
        // Usage
        return FromSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let formSection = FromSection(rawValue: Int(indexPath.row)) {
            let cell = getMenuItemCell(indexPath: indexPath)
            cell.setup(forSection: formSection, isOn: self.selectedSection == formSection, isExpanded: self.isExpanded, clicked: {
                self.scrollToForm(section: formSection)
            })
            return cell
        } else {
            fatalError()
        }
    }
    
}
