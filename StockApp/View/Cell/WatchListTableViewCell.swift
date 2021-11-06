//
//  WatchListTableViewCell.swift
//  StockApp
//
//  Created by L on 2021/11/6.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell {
    
    // MARK: - ViewModel
    
    weak var delegate: WatchListTableViewCellDelegate?
    
    static let preferredHeight: CGFloat = 60

    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String // 格式化
        let changeColor: UIColor // 紅或綠色
        let changePercentage: String // 格式化
        let chartViewModel: StockChartView.ViewModel
        
    }
    
    // MARK: - Properties
    
    /// 股票名縮寫 Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    /// 公司名 Label
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    /// 價格 Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    /// 漲跌幅 Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    /// mini Chart
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
//        chart.backgroundColor = .link
        chart.clipsToBounds = true
        return chart
    }()
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.clipsToBounds = true
        
        addSubview(symbolLabel)
        addSubview(companyNameLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(miniChartView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        companyNameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()

        let yStart: CGFloat = (contentView.height - symbolLabel.height - companyNameLabel.height)/2
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height
        )

        companyNameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: companyNameLabel.width,
            height: companyNameLabel.height
        )

        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
        )

        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }

        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height)/2,
            width: currentWidth,
            height: priceLabel.height
        )

        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )

        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width/3) - 5,
            y: 6,
            width: contentView.width/3,
            height: contentView.height-12
        )
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
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // configure chart
    }
}
