//
//  ViewController.swift
//  TestForTableView
//
//  Created by Sid on 15/05/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import UIKit
import JSONTableView

class ViewController: UIViewController {

    @IBOutlet weak var jsonTableView: UITableView!
    
    let helper = JSONTableView.JSONTableViewHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.jsonTableView.delegate = helper
        self.jsonTableView.dataSource = helper
        helper.viewDidLoad(tableView: jsonTableView)
    }


}

