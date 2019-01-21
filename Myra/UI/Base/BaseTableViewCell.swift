//
//  BaseTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-20.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell, Theme {

    func getPresenter() -> MainViewController? {
        guard let parent = self.parentViewController, let base = parent as? BaseViewController else { return nil}
        return base.getPresenter()
    }

}
