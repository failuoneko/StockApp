//
//  SearchResultsTableViewCell.swift
//  StockApp
//
//  Created by L on 2021/11/3.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Selectors
    
    
    
    // MARK: - Helpers
    
    func configureUI() {
    }
    
}
