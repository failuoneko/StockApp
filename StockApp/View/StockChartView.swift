//
//  StockChartView.swift
//  StockApp
//
//  Created by L on 2021/11/6.
//

import UIKit

class StockChartView: UIView {
    
    /// Chart View ViewModel
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
//        let fillColor: UIColor
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Selectors
    
    
    
    // MARK: - Helpers
    
    func resetChartView() {
        
    }
    
    func configure(with viewModel: ViewModel) {
        
    }
    
    func configureUI() {
        
    }
    
}
