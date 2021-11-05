//
//  ReuseCell.swift
//  StockApp
//
//  Created by L on 2021/11/3.
//

import UIKit

extension UICollectionReusableView {
    static var id: String {
        return "\(Self.self)"
    }
}

extension UITableViewCell {
    static var id: String {
        return "\(Self.self)"
    }
}

extension UITableViewHeaderFooterView {
    static var id: String {
        return "\(Self.self)"
    }
}

extension UICollectionViewController {
    static var id: String {
        return "\(Self.self)"
    }
}
