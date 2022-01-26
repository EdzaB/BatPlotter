//
//  UIView+Constraints.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import UIKit

public protocol LayoutGuideProvider {
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: LayoutGuideProvider {}

extension UILayoutGuide: LayoutGuideProvider {}

// MARK: Constrain to fill view
public extension UIView {

    @discardableResult
    func constrainTo(_ view: LayoutGuideProvider, withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left))
        constraints.append(view.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right))
        constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top))
        constraints.append(view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom))

        return constraints
    }

    @discardableResult
    func constrainTo(_ view: LayoutGuideProvider, withInsets inset: CGFloat = 0) -> [NSLayoutConstraint] {
        let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        return constrainTo(view, withInsets: insets)
    }
}

// MARK: Constrain to superview
public extension UIView {

    @discardableResult
    func constrainToSuperview(withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        guard let superview = superview else {
            fatalError("Error adding auto constraints to fill parent view: This view has no parent.")
        }

        return constrainTo(superview, withInsets: insets)
    }

    @discardableResult
    func constrainToSuperview(withInsets inset: CGFloat = 0) -> [NSLayoutConstraint] {
        let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        return constrainToSuperview(withInsets: insets)
    }
}

// MARK: Aspect ratio lock
public extension UIView {

    @discardableResult
    func constrainAspectRatio(to ratio: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: ratio, constant: 0)
    }

    @discardableResult
    func constrainAspectRatio(to image: UIImage) -> NSLayoutConstraint {
        let ratio = image.size.width / image.size.height
        return constrainAspectRatio(to: ratio)
    }
}

public extension Collection where Element == NSLayoutConstraint {
    @discardableResult
    func activate() -> Self {
        forEach { $0.isActive = true }
        return self
    }
}

public extension NSLayoutConstraint {
    @discardableResult
    func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }
}
