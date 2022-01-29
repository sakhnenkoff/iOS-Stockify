//
//  SearchResponse.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 25.01.2022.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResults]
}

struct SearchResults: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
