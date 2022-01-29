//
//  Extensions.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 23.01.2022.
//

import Foundation
import UIKit

//MARK: - String

extension String {
    static func string(from timeinterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeinterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
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
}
