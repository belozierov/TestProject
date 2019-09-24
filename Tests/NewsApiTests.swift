//
//  NewsApiTests.swift
//  Tests
//
//  Created by Alex Belozierov on 9/22/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreDataJsonParser
@testable import Example

class NewsApiTests: XCTestCase {
    
    let newsApi = NYTimesService.shared
    
    func testNYTimesNewsGetURL() {
        guard let url = newsApi?.everythingUrl(search: "ukraine", page: 1),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
            else { return XCTFail() }
        XCTAssertTrue(url.absoluteString.hasPrefix("https://api.nytimes.com/svc/search"))
        XCTAssertTrue(components.contains { $0.name == "q" && $0.value == "ukraine" })
        XCTAssertTrue(components.contains { $0.name == "sort" && $0.value == "newest" })
        XCTAssertTrue(components.contains { $0.name == "page" && $0.value == "1" })
    }
    
    func testNYTimesNewsGetJson() {
        XCTAssertNotNil(newsApi)
        let expectation = XCTestExpectation(description: "Download json")
        
        newsApi?.getNews(search: "ukraine", page: 0) { result in
            switch result {
            case .success(let json):
                XCTAssertEqual(json.response?.docs?.array?.count, 10)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60)
    }
    
}
