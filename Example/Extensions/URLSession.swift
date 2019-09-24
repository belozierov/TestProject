//
//  URLSession.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreDataJsonParser
import Foundation

extension URLSession {
    
    func dataTask(with url: URL, completion: @escaping (Result<Json, Error>) -> Void) -> URLSessionDataTask {
        dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)) }
            else if let json = data.flatMap(Json.init) { completion(.success(json)) }
            else { completion(.failure(URLError(.cannotParseResponse))) }
        }
    }
    
}
