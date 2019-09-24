//
//  PaginatorPageData.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

protocol PaginatorPageData {
    
    associatedtype InitData
    init(previous: Self?, data: InitData) throws
    var loaded: Int { get }
    var isLast: Bool { get }
    
}

extension PaginatorPageData where Self: Decodable, InitData == Data {
    
    init(previous: Self?, data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
    
}
