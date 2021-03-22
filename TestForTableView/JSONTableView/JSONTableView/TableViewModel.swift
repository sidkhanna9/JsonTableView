//
//  TableViewModel.swift
//  JSONTableView
//
//  Created by Sid on 15/05/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import UIKit

class TableViewModel: Codable {
    var tableViewId: String?
    var sections: [SectionModel]?
    var contentInset: Constraint?
}

class SectionModel: Codable {
    var sectionName: String?
    var rows: [RowsModel]?
}

class RowsModel: Codable {
    var view: ModelForViews?
    var rowId: String?
    var removeViewsWithTag: [Int]?
}
