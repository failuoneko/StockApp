//
//  Extensions.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import Foundation
import UIKit

// MARK: - TimeInterval -> String

extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.newsDateFormatter.string(from: date)
    }
}


// MARK: - DateFormat

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}


// MARK: - Framing

extension UIView {
    /// Width of view
    var width: CGFloat {
        frame.size.width
    }

    /// Height of view
    var height: CGFloat {
        frame.size.height
    }

    /// Left edge of view
    var left: CGFloat {
        frame.origin.x
    }

    /// Right edge of view
    var right: CGFloat {
        left + width
    }

    /// Top edge of view
    var top: CGFloat {
        frame.origin.y
    }

    /// Bottom edge of view
    var bottom: CGFloat {
        top + height
    }
}
