//
//  StockChartView.swift
//  StockApp
//
//  Created by L on 2021/11/6.
//

import UIKit
import Charts

class StockChartView: UIView {
    
    /// Chart View ViewModel
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool // 顯示大走勢圖下方"■ 資料"
        let showAxis: Bool // 顯示價格線"
        let fillColor: UIColor
    }
    
    // MARK: - Properties
    
    /// Chart View
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)  // 允許圖表可以被縮放
        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false // 是否要畫網格線
        chartView.legend.enabled = false // 是否顯示"■ 7 Days"
        return chartView
    }()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Helpers
    
    func resetChartView() {
        chartView.data = nil
    }
    
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()

        for (index, value) in viewModel.data.enumerated() {
            entries.append(.init(x: Double(index), y: value))
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend

        let dataSet = LineChartDataSet(entries: entries, label: "\(numberOfDays.Days) Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true // 是否填充顏色
        dataSet.drawIconsEnabled = false // 是否繪製圖標
        dataSet.drawValuesEnabled = false // 是否在拐點處顯示數據
        dataSet.drawCirclesEnabled = false // 是否繪製拐點
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data

    }
    
    func configureUI() {
        addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
