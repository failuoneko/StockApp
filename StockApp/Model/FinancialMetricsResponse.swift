//
//  FinancialMetricsResponse.swift
//  StockApp
//
//  Created by L on 2021/11/7.
//

import Foundation

// API - Basic Financials - Sample response: https://finnhub.io/docs/api/company-basic-financials

/// Metrics response from API
struct FinancialMetricsResponse: Codable {
    let metric: Metrics
}

/// 財務指標。
struct Metrics: Codable {
    let TenDayAverageTradingVolume: Float
    let AnnualWeekHigh: Double
    let AnnualWeekLow: Double
    let AnnualWeekLowDate: String
    let AnnualWeekPriceReturnDaily: Float
    let beta: Float

    enum CodingKeys: String, CodingKey {
        case TenDayAverageTradingVolume = "10DayAverageTradingVolume"
        case AnnualWeekHigh = "52WeekHigh"
        case AnnualWeekLow = "52WeekLow"
        case AnnualWeekLowDate = "52WeekLowDate"
        case AnnualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
    }
}
