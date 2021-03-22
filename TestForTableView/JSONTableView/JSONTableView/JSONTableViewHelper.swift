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
    
    public func viewDidLoad(tableView: UITableView) {
        jsonTableView?.sections?.forEach({$0.rows?.forEach({tableView.register(UITableViewCell.self, forCellReuseIdentifier: $0.rowId ?? "") })})
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
        guard let row = self.jsonTableView?.sections?[indexPath.section].rows?[indexPath.row], let rowId = row.rowId, let cell = tableView.dequeueReusableCell(withIdentifier: rowId) else {
            return UITableViewCell()
        }
        let rowModelInitializer = self.recursiveInitializeView(tableViewCell: cell, modelForView: row.view)
        if let view = rowModelInitializer.view {
            let subViews = view.subviewsRecursive()
            row.removeViewsWithTag?.forEach({ (tag) in
                subViews.first{$0.tag == tag}?.removeFromSuperview()
            })
            cell.contentView.addSubview(view)
            self.recursizeConstraints(modelForView: row.view, rowModelInitializer.dict)
            cell.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            cell.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            cell.contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            cell.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        return cell
    }
    
    private func recursizeConstraints(modelForView: ModelForViews?, _ dict: [Int: UIView]?) {
        guard let modelForView = modelForView, let tag = modelForView.tag else { return }
        modelForView.constraints?.forEach({ (constraint) in
            if let view = dict?[tag], let secondTag = constraint.toView,
                let secondView = dict?[secondTag], let fromAttribute = constraint.fromDimension,
                let toAttribute = constraint.toDimension, let relatedBy = constraint.relatedBy,
                let multiplier = constraint.multiplier, let constant = constraint.constant {
                // Attribute: 1 - left, 2 - right, 3 - top, 4 - bottom
                // Relation: -1 = lessThanOrEqual, 0 = equal, 1 = greaterThanOrEqualTo
                NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute(rawValue: fromAttribute)!, relatedBy: NSLayoutConstraint.Relation(rawValue: relatedBy)!, toItem: secondView, attribute: NSLayoutConstraint.Attribute(rawValue: toAttribute)!, multiplier: CGFloat(multiplier), constant: CGFloat(constant)).isActive = true
            } else if let view = dict?[tag], let fromAttribute = constraint.fromDimension, let relatedBy = constraint.relatedBy, let multiplier = constraint.multiplier, let constant = constraint.constant {
                NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute(rawValue: fromAttribute)!, relatedBy: NSLayoutConstraint.Relation(rawValue: relatedBy)!, toItem: nil, attribute: NSLayoutConstraint.Attribute(rawValue: 0)!, multiplier: CGFloat(multiplier), constant: CGFloat(constant)).isActive = true
            }
        })
        modelForView.subViews?.forEach({
            self.recursizeConstraints(modelForView: $0, dict)
        })
    }
    
    private func recursiveInitializeView(tableViewCell: UITableViewCell, modelForView: ModelForViews?) -> (view: UIView?, dict: [Int: UIView]?) {
        guard let modelForView = modelForView, let tag = modelForView.tag else { return (nil, nil) }
        var view: UIView = UIView()
        if let customView = tableViewCell.viewWithTag(tag) {
            view = customView
        } else if let viewType = modelForView.viewType, let viewFromModel: AnyObject.Type = NSClassFromString(viewType), let uiViewType = viewFromModel as? UIView.Type {
            view = uiViewType.init()
            view.tag = tag
        }
        
        var dict: [Int: UIView] = [:]
        dict[tag] = view
        
        view.translatesAutoresizingMaskIntoConstraints = false
        modelForView.propertyList?.forEach({
            self.setProperty(object: view, name: $0.key, propertyList: $0.value)
        })
        
        modelForView.subViews?.forEach({
            let childRecursiveResult = self.recursiveInitializeView(tableViewCell: tableViewCell, modelForView: $0)
            if let childView = childRecursiveResult.view {
                view.addSubview(childView)
            }
            if let childDict = childRecursiveResult.dict {
                childDict.keys.forEach({
                    dict[$0] = childDict[$0]
                })
            }
        })
        return (view: view, dict: dict)
    }
    
    func setProperty(object: UIView, name: String, propertyList: PropertyList) {
        var value: Any? = nil
        guard let property = propertyList.type, let propertyType = PropertyType(rawValue: property), let values = propertyList.value else {
            return
        }
        switch(propertyType) {
        case .uiColor:
            value = UIColor(red: CGFloat(values[0])! / 255.0, green: CGFloat(values[1])! / CGFloat(255), blue: CGFloat(values[2])! / CGFloat(255), alpha: CGFloat(values[3])!)
        case .attributedString:
            // color from string (may be we can consider using hex here)
            value = values[0].attributedString(color: .black, fontName: values[2], fontSize: CGFloat(values[3]) ?? 16)
        case .buttonAttributedString:
            (object as? UIButton)?.setAttributedTitle(values[0].attributedString(), for: .normal)
            return
        case .buttonWithImageUrl:
            return
            // async UIImage From Url
        case .buttonWithImageAsset:
            (object as? UIButton)?.setImage(UIImage(named: values[0]), for: .normal)
            return
            // other properties
        case .bool:
            value = Bool(values[0])
        case .double:
            value = Double(values[0])
        case .cgFloat:
            value = CGFloat(values[0])
        case .int:
            value = Int(values[0])
        case .float:
            value = Float(values[0])
        case .imageFromUrl:
            // async UIImage from Url
            URLSession.shared.dataTask(with: URL(string: values[0])!, completionHandler: { data,response,error in
                guard let data = data, error == nil, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    object.setValue(image, forKeyPath: name)
                    if values.count > 1, let contentMode: UIView.ContentMode = UIView.ContentMode.init(rawValue: Int(values[1]) ?? 1) {
                        object.contentMode = contentMode
                    }
                }
            }).resume()
            return
        case .imageFromAsset:
            guard let image = UIImage(named: values[0]) else { return }
            value = image
        case .contentHorizontalHuggingProperty:
            object.setContentHuggingPriority(getPriority(string: values[0]), for: .horizontal)
            return
        case .contentVerticalHuggingProperty:
            object.setContentHuggingPriority(getPriority(string: values[0]), for: .vertical)
            return
        case .contentHorizontalCompressionResistance:
            object.setContentCompressionResistancePriority(getPriority(string: values[0]), for: .horizontal)
            return
        case .contentVerticalCompressionResistance:
            object.setContentCompressionResistancePriority(getPriority(string: values[0]), for: .vertical)
            return
        case .string:
            value = values[0]
        case .tapGesture:
            object.addTapGestureRecognizer {
                let appUrl = URL(string: values[0])
                UIApplication.shared.open(appUrl!)
            }
            return
        }
        object.setValue(value, forKeyPath: name)
    }

    func getPriority(string: String) -> UILayoutPriority {
        return UILayoutPriority.init(rawValue: Float(string)!)
    }

}


extension CGFloat {
    init?(_ str: String) {
        guard let float = Double(str) else { return nil }
        self = CGFloat(float)
    }
}

extension String {
    func attributedString(color: UIColor = .black, fontName: String = "Effra-Regular", fontSize: CGFloat = 16) -> NSMutableAttributedString {
        var _font = UIFont.systemFont(ofSize: fontSize)
        if !fontName.isEmpty,
            let _customFont = UIFont(name: fontName, size: fontSize) {
            _font = _customFont
        }
        
        let _attrString = NSMutableAttributedString.init(string: self, attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : _font])
        return _attrString
    }
}
