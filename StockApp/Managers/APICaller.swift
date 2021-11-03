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
    }
    
    private init() {}
    
    // MARK: - Public
    
    // get stock info
    
    // search stocks
    public func searchStocks(query: String, completion: @escaping (Result<SearchUrlRresponse, Error>) -> Void) {
//        guard let url = url(for: .search, queryParams: ["q":query]) else { return }
        
        // 特殊字元或中文字時轉換文字。
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(for: .search, queryParams: ["q": safeQuery]), expecting: SearchUrlRresponse.self, completion: completion)
//        print("DEBUG: absoluteURL: [\(url.absoluteURL)]")
    }

    // MARK: - Private
    
    private enum Endpoint: String {
        case search
    }
    
    // 定義錯誤。
    private enum APIError: Error {
        case noDataReturnde
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
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        print("DEBUG: urlString: [\(urlString)]")
        
        return URL(string: urlString)
    }
    
    // request 解析URL
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion:@escaping (Result<T, Error>) -> Void) {
        
        guard let url = url else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                print("DEBUG:error = [\(error.localizedDescription)]")
                return
            } else {
                completion(.failure(APIError.noDataReturnde))
            }
            
            guard let data = data else { return }
            
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
