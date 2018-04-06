//
//  Extensions.swift
//  NetworkReachability
//
//  Created by Xinyuan's on 3/1/18.
//  Copyright © 2018 Xinyuan Wang. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public typealias VerticalAnchorPair = (anchor: NSLayoutYAxisAnchor?, constant: CGFloat)
    
    public typealias HorizontalAnchorPair = (anchor: NSLayoutXAxisAnchor?, constant: CGFloat)
    
    public func attachEdgeTo(top: VerticalAnchorPair = (nil, 0), bottom: VerticalAnchorPair = (nil, 0), leading: HorizontalAnchorPair = (nil, 0), trailing: HorizontalAnchorPair = (nil, 0), left: HorizontalAnchorPair = (nil, 0), right: HorizontalAnchorPair = (nil, 0)) {
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        if let topAnchor = top.anchor {
            _ = verticalLayout(to: topAnchor, constant:top.constant,position: .top)
        }
        if let bottomAnchor = bottom.anchor {
            _ = verticalLayout(to: bottomAnchor, constant:bottom.constant, position: .bottom)
        }
        if let leadingAnchor = leading.anchor {
            _ = horizontalLayout(to: leadingAnchor, constant: leading.constant, position: .leading)
        }else if isLeftToRight, let leftAnchor = left.anchor {
            _ = horizontalLayout(to: leftAnchor, position: .left)
        }else if !isLeftToRight, let rightAnchor = right.anchor {
            _ = horizontalLayout(to: rightAnchor, constant: right.constant, position: .right)
        }
        
        if let trailingAnchor = trailing.anchor {
            _ = horizontalLayout(to: trailingAnchor, constant: trailing.constant, position: .trailing)
        }else if isLeftToRight, let rightAnchor = right.anchor {
            _ = horizontalLayout(to: rightAnchor,constant: right.constant, position: .right)
        }else if !isLeftToRight, let leftAnchor = left.anchor {
            _ = horizontalLayout(to: leftAnchor,constant: left.constant, position: .left)
        }
    }
    
    public func layout(toCenterX centerX: HorizontalAnchorPair = (nil, 0), centerY: VerticalAnchorPair = (nil, 0)) {
        if let x = centerX.anchor {
            _ = horizontalLayout(to: x, constant: centerX.constant, position: .centerX)
        }
        if let y = centerY.anchor {
            _ = verticalLayout(to: y, constant: centerY.constant, position: .centerY)
        }
    }
    
    internal func verticalLayout(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, position: NSLayoutConstraint.LayoutPosition) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        var selfAnchor: NSLayoutYAxisAnchor? = nil
        switch position {
        case .top:
            selfAnchor = topAnchor
            break
        case .bottom:
            selfAnchor = bottomAnchor
            break
        case .centerY:
            selfAnchor = centerYAnchor
            break
        default:
            break
        }
        let const = selfAnchor?.constraint(equalTo: anchor, constant: constant)
        const?.type = position
        const?.isActive = true
        return const
    }
    
    internal func horizontalLayout(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, position:NSLayoutConstraint.LayoutPosition) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        var selfAnchor: NSLayoutXAxisAnchor? = nil
        switch position {
        case .leading:
            selfAnchor = leadingAnchor
            break
        case .trailing:
            selfAnchor = trailingAnchor
            break
        case .left:
            selfAnchor = leftAnchor
            break
        case .right:
            selfAnchor = rightAnchor
            break
        case .centerX:
            selfAnchor = centerXAnchor
            break
        default:
            break
        }
        let const = selfAnchor?.constraint(equalTo: anchor, constant: constant)
        const?.type = position
        const?.isActive = true
        return const
    }
    
    public func dimensionLayout(to anchor: NSLayoutDimension? = nil, constant: CGFloat, position: NSLayoutConstraint.LayoutPosition) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        var selfAnchor: NSLayoutDimension? = nil
        var cons: NSLayoutConstraint? = nil
        switch position {
        case .height:
            selfAnchor = heightAnchor
            break
        case .width:
            selfAnchor = widthAnchor
            break
        default:
            break
        }
        if let anch = anchor {
            cons = selfAnchor?.constraint(equalTo: anch, multiplier: 1, constant: constant)
        }else {
            cons = selfAnchor?.constraint(equalToConstant: constant)
        }
        cons?.type = position
        cons?.isActive = true
        return cons
    }
    
    public func constraint(for type: NSLayoutConstraint.LayoutPosition) -> NSLayoutConstraint? {
        guard let index = constraints.index(where: {$0.type == .some(type)}) else { return nil }
        return constraints[index]
    }
}

extension NSLayoutConstraint {
    
    public enum LayoutPosition: String {
        case top = "Top", bottom = "Bottom", leading = "Leading", trailing = "Trailing", left = "Left", right = "Right", height = "Height", width = "Width", centerX = "CenterX", centerY = "CenterY"
    }
    
    public var type: LayoutPosition? {
        get {
            guard let id = self.identifier else { return nil }
            return LayoutPosition(rawValue: id)
        }
        set {
            self.identifier = newValue?.rawValue
        }
    }
}
