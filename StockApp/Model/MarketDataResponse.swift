//
//  MarketDataResponse.swift
//  StockApp
//
//  Created by L on 2021/11/6.
//

import Foundation

struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let status: String
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case high = "h"
        case low = "l"
        case status = "s"
        case timestamps = "t"
    }
    
    var candleSticks: [CandleStick] {
        var result: [CandleStick] = []
        for index in 0..<open.count {
            result.append(.init(open: open[index],
                                close: close[index],
                                high: high[index],
                                low: low[index],
                                date: Date(timeIntervalSince1970: timestamps[index])))
        }
        // 時間新到舊排序。
        let sortedData = result.sorted(by: { $0.date > $1.date})
//        print("DEBUG: sortedData: \(sortedData[0])")
        return sortedData
    }
}

struct CandleStick {
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let date: Date
}
