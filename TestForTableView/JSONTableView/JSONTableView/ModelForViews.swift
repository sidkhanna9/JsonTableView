//
//  ModelForViews.swift
//  JSONTableView
//
//  Created by Sid on 15/05/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import UIKit

class ModelForViews: Codable {
    var viewName: String?
    var viewType: String?
    var backgroundColor: Color?
    var subViews: [ModelForViews]?
    var constraints: [Constraint]?
}

class Constraint: Codable {
    var toView: String?
    var constant: Int?
    var multiplier: Int?
    var fromDimension: String?
    var toDimension: String?
}

class Color: Codable {
    var colorR: Float?
    var colorG: Float?
    var colorB: Float?
    var colorA: Float?
}
