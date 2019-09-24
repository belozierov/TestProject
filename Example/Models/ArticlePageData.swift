//
//  ArticlePageData.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreDataJsonParser

struct ArticlePageData: PaginatorPageData {
    
    let loaded, total: Int
    var isLast: Bool { loaded >= total }
    
    init(previous: ArticlePageData?, data: Json) throws {
        let offset: Int = try data.tryMap { $0.response?.meta?.offset }
        let articles = try data.tryMap { $0.response?.docs?.array?.count }
        loaded = offset + articles
        try total = data.tryMap { $0.response?.meta?.hits }
    }
    
}
