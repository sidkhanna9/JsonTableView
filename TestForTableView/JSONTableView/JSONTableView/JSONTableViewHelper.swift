//
//  JSONTableViewHelper.swift
//  JSONTableView
//
//  Created by Sid on 15/05/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import UIKit

public class JSONTableViewHelper: NSObject {
    
    var jsonTableView: TableViewModel?
    
    public override init() {
        if let path = Bundle.init(identifier: "com.test.JSONTableView")?.path(forResource: "test", ofType: "json") ,
            
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: []),
            let jsonResult = try? JSONDecoder().decode(TableViewModel.self, from: data) {
            self.jsonTableView = jsonResult
        }
    }
}

extension JSONTableViewHelper: UITableViewDelegate {
    
}

extension JSONTableViewHelper: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.jsonTableView?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.jsonTableView?.sections?[section].rows?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let row = self.jsonTableView?.sections?[indexPath.section].rows?[indexPath.row]  {
            
            return UITableViewCell()
        } else {
            return UITableViewCell()
        }
    }
}
