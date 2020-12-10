//
//  PropertyType.swift
//  JSONTableView
//
//  Created by Amirthy Tejeshwar on 10/12/20.
//  Copyright © 2020 Sid. All rights reserved.
//

import Foundation

enum PropertyType: String, CaseIterable {
    case uiColor = "UIColor"
    case attributedString = "NSAttributedString"
    case buttonAttributedString = "ButtonAttributedString"
    case buttonWithImageUrl = "ButtonWithImageUrl"
    case buttonWithImageAsset = "ButtonWithImageAsset"
    case int = "Int"
    case string = "String"
    case double = "Double"
    case float = "Float"
    case bool = "Bool"
    case cgFloat = "CGFloat"
    case imageFromUrl = "ImageFromUrl"
    case imageFromAsset = "ImageFromAsset"
    case contentHorizontalHuggingProperty = "ContentHorizontalHuggingProperty"
    case contentVerticalHuggingProperty = "ContentVerticalHuggingProperty"
    case contentHorizontalCompressionResistance = "ContentHorizontalCompressionResistance"
    case contentVerticalCompressionResistance = "ContentVerticalCompressionResistance"
}
