//
//  Extensions.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 23.01.2022.
//

import Foundation
import UIKit
import SnapKit


//MARK: - Notification

extension Notification.Name {
    static let didAddToWatchlist = Notification.Name("didAddToWatchList")
}

//MARK: - UIStackView

extension UIStackView {
    static func simpleStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment = .center, distribution: Distribution) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        return stack
    }
    
    public func addArrangedSubview(views: UIView...) {
        views.forEach { view in
            self.addArrangedSubview(view)
        }
    }
}

//MARK: - NumberFormatter

extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

//MARK: - String

extension String {
    static func string(from timeinterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeinterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatter(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

//MARK: - Date Formatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

//MARK: - Add Subview

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            addSubview(view)
        }
    }
}

//MARK: - Framing

extension UIView {
    var width: CGFloat { frame.size.width }
    var height: CGFloat { frame.size.height }
    var left: CGFloat { frame.origin.x }
    var right: CGFloat { left + width }
    var top: CGFloat { frame.origin.y }
    var bottom: CGFloat { frame.origin.y + height }
    
    func setWidth(width: CGFloat) {
        self.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
}
