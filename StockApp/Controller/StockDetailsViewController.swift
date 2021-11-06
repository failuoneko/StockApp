//
//  StockDetailsViewController.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import UIKit

class StockDetailsViewController: UIViewController {
    // 顯示股票代號、公司名、走勢圖等等。
    
    // MARK: - Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    

    // MARK: - Init

    init(symbol: String, companyName: String, candleStickData: [CandleStick] = [] ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
    }
}
