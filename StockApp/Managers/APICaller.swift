//
//  APICaller.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "c60o6niad3ifmvvnnncg"
        static let sandboxApiKey = "sandbox_c60o6niad3ifmvvnnnd0"
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let oneDay: TimeInterval = 60 * 60 * 24
    }
    
    private init() {}
    
    // MARK: - Public
    
    // search stocks
    public func searchStocks(query: String, completion: @escaping (Result<SearchUrlResponse, Error>) -> Void) {
        
        // 特殊字元或中文字時轉換文字。
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let url = url(for: .search, queryParams: ["q": safeQuery])
        request(url: url, expecting: SearchUrlResponse.self, completion: completion)
        //        print("DEBUG: absoluteURL: [\(url.absoluteURL)]")
    }
    
    // fetchNews
    public func fetchNews(for type:NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        
        switch type {
        case .news:
            request(url: url(for: .news, queryParams: ["category": "general"]), expecting: [NewsStory].self, completion: completion)
        case .company(symbol: let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.oneDay * 7))
            request(url: url(for: .companyNews, queryParams: ["symbol": symbol,
                                                              "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                                              "to":DateFormatter.newsDateFormatter.string(from: today)]),
                    expecting: [NewsStory].self, completion: completion)
        }
    }
    
    /// 獲取股票資料。
    public func fetchMarketData(
        for symbol: String,
        numberOfDays: TimeInterval = TimeInterval(numberOfDays.Days),
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
        let today = Date().addingTimeInterval(-(Constants.oneDay))
        let priot = today.addingTimeInterval(-(Constants.oneDay * numberOfDays))
        request(
            url: url(
                for: .marketData,
                queryParams: ["symbol": symbol,
                              "resolution": "1",
                              "from": "\(Int(priot.timeIntervalSince1970))",
                              "to": "\(Int(today.timeIntervalSince1970))"]),
                expecting: MarketDataResponse.self, completion: completion)
    }
    
    /// 獲取財務指標。
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void) {
        request(
            url: url(
                for: .financials,
                queryParams: ["symbol": symbol, "metric": "all"]),
            expecting: FinancialMetricsResponse.self, completion: completion)
    }
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
        case news = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    // 定義錯誤。
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems: [URLQueryItem] = []
        // 傳入任意參數。
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // 將查詢結果轉換為String
        // 產生結果範例：[https://finnhub.io/api/v1/company-news?to=2021-11-05&symbol=MSFT&from=2021-10-29&token=c60o6niad3ifmvvnnncg]
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
//        print("DEBUG: urlString: [\(urlString)]")
        
        return URL(string: urlString)
    }
    
    // request 解析URL
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            // 網址無效時。
            completion(.failure(APIError.invalidUrl))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
