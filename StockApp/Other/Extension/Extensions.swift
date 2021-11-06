//
//  Extensions.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import Foundation
import UIKit

// MARK: - NumberFormatter

extension NumberFormatter {
    /// 百分比 NumberFormatter
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    /// 小數點 NumberFormatter
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - TimeInterval -> String

extension String {
    /// 以時間間隔創建字串。（TimeInterval -> String）
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    /// 格式化成百分比字串。（Double-> String）
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    /// 格式化成小數點字串。（Double-> String）
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
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


//// MARK: - Framing
//
//extension UIView {
//    /// Width of view
//    var width: CGFloat {
//        frame.size.width
//    }
//
//    /// Height of view
//    var height: CGFloat {
//        frame.size.height
//    }
//
//    /// Left edge of view
//    var left: CGFloat {
//        frame.origin.x
//    }
//
//    /// Right edge of view
//    var right: CGFloat {
//        left + width
//    }
//
//    /// Top edge of view
//    var top: CGFloat {
//        frame.origin.y
//    }
//
//    /// Bottom edge of view
//    var bottom: CGFloat {
//        top + height
//    }
//}
