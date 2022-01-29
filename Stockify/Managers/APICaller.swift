//
//  APICaller.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "c7n9mhiad3ifj5l0a3i0"
        static let sandBoxApiKey = "sandbox_c7n9mhiad3ifj5l0a3ig"
        static let baseUrl = "https://finnhub.io/api/v1/"
        
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() {}
    
    //MARK: - Public
    
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(for: .search, queryParams: ["q":safeQuery]), expecting: SearchResponse.self, completion: completion)
    }
    
    public func news(for type: NewsViewController.TypeOfVC, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        let oneWeekBack = Date().addingTimeInterval(-(Constants.day * 7))
        
        switch type {
        case .topStories:
            let url = url(for: .news, queryParams: ["category":"general"])
            request(url: url, expecting: [NewsStory].self, completion: completion)
        case .company(symbol: let symbol):
            let url = url(for: .companyNews, queryParams: [
                "symbol":symbol,
                "from": DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                "to": DateFormatter.newsDateFormatter.string(from: Date())
            ])
            request(url: url, expecting: [NewsStory].self, completion: completion)
        }
        
    }
    
    //MARK: - Private
    
    private enum Endpoint: String {
        case search
        case news
        case companyNews = "company-news"
    }
    
    private enum APIErrors: Error {
        case invalidUrl
        case noDataReturned
    }
    
    private func url(for endpoint: Endpoint, queryParams: [String:String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        // add params to the url
        
        for (key, value) in queryParams {
            queryItems.append(.init(name: key, value: value))
        }
                
        // add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // convert query params to suffix string
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        urlString += "?" + queryString
        
        print(urlString)
        
        return URL(string: urlString)
    }
        
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIErrors.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIErrors.noDataReturned))
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                    completion(.failure(error))
            }
            
        }
        task.resume()
    }
    
}
