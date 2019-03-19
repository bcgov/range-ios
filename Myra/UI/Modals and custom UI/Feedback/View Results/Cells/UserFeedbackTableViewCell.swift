//
//  UserFeedbackTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class UserFeedbackTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var feedbackHeader: UILabel!
    @IBOutlet weak var sectionHeader: UILabel!
    @IBOutlet weak var userHeader: UILabel!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var section: UILabel!
    @IBOutlet weak var userFeedback: UILabel!
    @IBOutlet weak var feedbackHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(with element: FeedbackElement) {
        styleFieldHeader(label: userHeader)
        styleFieldHeader(label: sectionHeader)
        styleFieldHeader(label: feedbackHeader)
        styleStaticField(field: user)
        styleStaticField(field: section)
        Feedback.removeButton()
        styleContainer(view: container)
        userFeedback.font = Fonts.getPrimary(size: 17)
        user.font = Fonts.getPrimary(size: 17)
        section.font = Fonts.getPrimary(size: 17)
        self.user.text = element.email
        self.section.text = element.section
        self.userFeedback.text = element.feedback
        self.feedbackHeight.constant = element.feedback.height(withConstrainedWidth: stack.frame.width, font: Fonts.getPrimary(size: 17))
    }
    
}
