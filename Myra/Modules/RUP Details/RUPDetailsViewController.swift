//
//  RUPDetailsViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-14.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class RUPDetailsViewController: BaseViewController {

    // MARK: Variables
    var rup: RUP?

    var isReadOnly: Bool = true
    var loaded: Bool = false

    // MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rupID: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loaded = true
        loadLoading()
        if rup != nil {setup()}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func set(rup: RUP, readOnly: Bool) {
        self.rup = rup
        self.isReadOnly = readOnly
        if loaded {
            setup()
            loadLoading()
        }
    }

    func setup() {
        // TODO: disable/ enable editing of fields instead
        if self.isReadOnly {
            self.containerView.backgroundColor = UIColor.red
            self.rupID.text = "\(String(describing: rup?.id)) View Mode"
        } else {
            self.containerView.backgroundColor = UIColor.blue
            self.rupID.text = "\(String(describing: rup?.id)) Ammend Mode"
        }
    }

    func loadLoading() {
        loading = getIoadingView()
        self.view.addSubview(loading!)
        loading?.startAnimating()
    }
}
