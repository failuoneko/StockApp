//
//  SearchURLresponse.swift
//  StockApp
//
//  Created by L on 2021/11/3.
//

import Foundation

struct SearchUrlResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
