//
//  NewsStory.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 26.01.2022.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: Double
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String    
}
