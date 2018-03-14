//
//  ScheduleCellTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class ScheduleCellTableViewCell: UITableViewCell {
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionsView: UIView!

    @IBOutlet weak var leadingOptions: NSLayoutConstraint!
    var schedule: Schedule?
    var rup: RUP?

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(schedule: Schedule) {
        self.schedule = schedule
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeLeft.direction = .left
//        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {

    }
    
    @IBAction func optionsAction(_ sender: Any) {
        print("show option")
        let width = optionsView.frame.width
        self.leadingOptions.constant = 0 - width
        animateIt()
    }

    @IBAction func detailAction(_ sender: Any) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        parent.showSchedule(object: schedule!)
    }

    func animateIt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }

    @IBAction func closeOptions(_ sender: Any) {
        let width = optionsView.frame.width
        self.leadingOptions.constant = 0
        animateIt()
    }

    func style() {
        let layer = cellContainer
        layer?.layer.cornerRadius = 3
        layer?.layer.borderWidth = 1
        layer?.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1).cgColor
    }
}
