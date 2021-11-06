//
//  WatchListTableViewCell.swift
//  StockApp
//
//  Created by L on 2021/11/6.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    
    
    // MARK: - ViewModel

    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String // 格式化
        let changeColor: UIColor // 紅或綠色
        let changePercentage: String // 格式化
        // let chartViewModel: StockChartView.ViewModel
        
    }
    
    // MARK: - Properties
    
    // Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // Company Label
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // Change Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // mini Chart
    private let miniChartView = StockChartView()
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(symbolLabel)
        addSubview(companyNameLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(miniChartView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyNameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.resetChartView()

    }
    
    // MARK: - Selectors
    
    
    
    // MARK: - Helpers
    
    func configureUI() {
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        companyNameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.companyName
        changeLabel.text = viewModel.price
        changeLabel.backgroundColor = viewModel.changeColor
        // configure chart
    }
}
