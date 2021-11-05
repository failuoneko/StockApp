//
//  NewsStory.swift
//  StockApp
//
//  Created by L on 2021/11/5.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
