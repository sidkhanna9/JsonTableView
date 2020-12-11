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
//    var viewsDictionary: [String: UIView] = [:]
    
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
        guard let row = self.jsonTableView?.sections?[indexPath.section].rows?[indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: "jsonView") else {
            return UITableViewCell()
        }
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
        if let view = self.recursiveInitializeView(modelForView: row.view) {
            cell.contentView.addSubview(view)
            self.recursizeConstraints(modelForView: row.view, cell.contentView)
            cell.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            cell.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            cell.contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            cell.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        return cell
    }
    
    private func recursizeConstraints(modelForView: ModelForViews?, _ parentView: UIView) {
        guard let modelForView = modelForView, let tag = modelForView.tag else { return }
        modelForView.constraints?.forEach({ (constraint) in
            if let view = parentView.viewWithTag(tag), let secondTag = constraint.toView,
                let secondView = parentView.viewWithTag(secondTag), let fromAttribute = constraint.fromDimension,
                let toAttribute = constraint.toDimension, let relatedBy = constraint.relatedBy,
                let multiplier = constraint.multiplier, let constant = constraint.constant {
                // Attribute: 1 - left, 2 - right, 3 - top, 4 - bottom
                // Relation: -1 = lessThanOrEqual, 0 = equal, 1 = greaterThanOrEqualTo
                NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute(rawValue: fromAttribute)!, relatedBy: NSLayoutConstraint.Relation(rawValue: relatedBy)!, toItem: secondView, attribute: NSLayoutConstraint.Attribute(rawValue: toAttribute)!, multiplier: CGFloat(multiplier), constant: CGFloat(constant)).isActive = true
            } else if let view = parentView.viewWithTag(tag), let fromAttribute = constraint.fromDimension, let relatedBy = constraint.relatedBy, let multiplier = constraint.multiplier, let constant = constraint.constant {
                NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute(rawValue: fromAttribute)!, relatedBy: NSLayoutConstraint.Relation(rawValue: relatedBy)!, toItem: nil, attribute: NSLayoutConstraint.Attribute(rawValue: 0)!, multiplier: CGFloat(multiplier), constant: CGFloat(constant)).isActive = true
            }
        })
        modelForView.subViews?.forEach({
            self.recursizeConstraints(modelForView: $0, parentView)
        })
    }
    
    private func recursiveInitializeView(modelForView: ModelForViews?) -> UIView? {
        guard let modelForView = modelForView else { return nil }
        let viewFromModel: AnyObject.Type  = NSClassFromString(modelForView.viewType!)!
        let uiViewType = viewFromModel as! UIView.Type
        let view = uiViewType.init()
        
//        if let viewName = modelForView.viewName {
//            self.viewsDictionary[viewName] = view
//        }
        if let tag = modelForView.tag {
            view.tag = tag
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        modelForView.propertyList?.forEach({
            self.setProperty(object: view, name: $0.key, propertyList: $0.value)
        })
        
        modelForView.subViews?.forEach({
            if let childView = self.recursiveInitializeView(modelForView: $0) {
                view.addSubview(childView)
            }
        })
        return view
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
