//
//  NewsApi.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation
import CoreDataJsonParser

protocol NewsApiService {
    
    func getNews(search: String, page: Int, completion: @escaping (Result<Json, Error>) -> Void)
    
}

struct NYTimesService: NewsApiService {
    
    static let shared = NYTimesService(path: "https://api.nytimes.com/svc/search",
                                       apiKey: "OUCmRkuoo2NIlfpCe9bQRAHAan0oNSEn")
    private let components: URLComponents
    
    init?(path: String, apiKey: String) {
        guard var components = URLComponents(string: path) else { return nil }
        components.queryItems = [.init(name: "api-key", value: apiKey)]
        self.components = components
    }
    
    func everythingUrl(search: String, page: Int) -> URL? {
        var components = self.components
        components.queryItems?.append(.init(name: "sort", value: "newest"))
        components.queryItems?.append(.init(name: "q", value: search))
        components.queryItems?.append(.init(name: "page", value: page.description))
        var url = components.url
        url?.appendPathComponent("v2/articlesearch.json")
        return url
    }
    
    func getNews(search: String, page: Int, completion: @escaping (Result<Json, Error>) -> Void) {
        guard let url = everythingUrl(search: search, page: page)
            else { return completion(.failure(URLError(.badURL))) }
        URLSession.shared.dataTask(with: url, completion: completion).resume()
    }
    
}
