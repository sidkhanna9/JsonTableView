//
//  ModelForViews.swift
//  JSONTableView
//
//  Created by Sid on 15/05/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import UIKit

class ModelForViews: Codable {
    var tag: Int?
    var viewType: String?
    var propertyList: [String: PropertyList]?
    var subViews: [ModelForViews]?
    var constraints: [Constraint]?
}

class PropertyList: Codable {
    var type: String?
    var value: [String]?
}

class Constraint: Codable {
    var toView: Int?
    var constant: Int?
    var multiplier: Int?
    var relatedBy: Int?
    var fromDimension: Int?
    var toDimension: Int?
}
