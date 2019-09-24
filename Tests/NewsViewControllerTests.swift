//
//  NewsViewControllerTests.swift
//  Tests
//
//  Created by Alex Belozierov on 9/20/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import CoreData
import CoreDataJsonParser
@testable import Example

class TestNewsTableViewControllerDelegate: NewsViewModelDelegate {
    
    weak var delegate: NewsViewModelDelegate?
    var updateHandler: (() -> Void)?
    
    func loadBegins() {
        delegate?.loadBegins()
    }
    
    func loadEnds() {
        delegate?.loadEnds()
    }
    
    func recieveError(_ error: Error) {
        delegate?.recieveError(error)
    }
    
    func dataDidUpdated(updates: [IndexPathUpdate]) {
        delegate?.dataDidUpdated(updates: updates)
        updateHandler?()
    }
    
}

class TestNewsApiService: NewsApiService {
    
    func getNews(search: String, page: Int, completion: @escaping (Result<Json, Error>) -> Void) {
        completion(.success(json))
    }
    
    lazy var json: Json = {
        let bundle = Bundle(for: TestNewsApiService.self)
        let path = bundle.path(forResource: "NewsJson", ofType: "json")
        let url = path.map { URL(fileURLWithPath: $0) }
        let data = try! Data(contentsOf: url!)
        return Json(data: data)!
    }()
    
}

class NewsViewControllerTests: XCTestCase {
    
    let apiService = TestNewsApiService()
    
    override func setUp() {
        super.setUp()
        clearContainer()
    }
    
    func testViewController() {
        clearContainer()
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsTableViewController") as! NewsTableViewController
        let delegate = TestNewsTableViewControllerDelegate()
        let viewModel = NewsViewModel(newsApiService: apiService, viewContext: container.viewContext, parseContext: container.viewContext)
        
        viewModel.delegate = delegate
        controller.loadViewIfNeeded()
        controller.viewModel = viewModel
        controller.tableView.reloadData()
        
        let expectation = XCTestExpectation(description: "Download json")
        XCTAssertEqual(viewModel.numberOfSections, 0)
        
        delegate.updateHandler = { [unowned controller] in
            let tableView = controller.tableView!
            XCTAssertEqual(controller.numberOfSections(in: tableView), 3)
            XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 0), 3)
            
            let item = controller.viewModel[IndexPath(row: 0, section: 0)]
            let cell = controller.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            XCTAssertTrue(cell is NewsTableViewCell)
            XCTAssertEqual((cell as? NewsTableViewCell)?.titleLabel.text, item.headline)
            XCTAssertEqual((cell as? NewsTableViewCell)?.descriptionLabel.text, item.snippet)
            XCTAssertEqual((cell as? NewsTableViewCell)?.keywordsLabel.text, item.date?.description)
            
            expectation.fulfill()
        }
        
        viewModel.reload()
        wait(for: [expectation], timeout: 10)
    }
    
    func testViewModel() {
        clearContainer()
        let expectation = XCTestExpectation(description: "Download json")
        let delegate = TestNewsTableViewControllerDelegate()
        let apiService = TestNewsApiService()
        let viewModel = NewsViewModel(newsApiService: TestNewsApiService(),
                                      viewContext: container.viewContext,
                                      parseContext: container.viewContext)
        viewModel.delegate = delegate
        XCTAssertEqual(viewModel.numberOfSections, 0)
        
        delegate.updateHandler = { [unowned viewModel, unowned apiService] in
            XCTAssertEqual(viewModel.numberOfSections, 3)
            XCTAssertEqual(viewModel.numberOfRows(in: 0), 3)
            XCTAssertEqual(viewModel.count, 10)
            XCTAssertFalse(viewModel.isEmpty)
            XCTAssertEqual(viewModel.itemIndex(for: IndexPath(item: 1, section: 1)), 4)
            
            let articleJson = apiService.json.response!.docs[0]!
            let article = viewModel[IndexPath(item: 0, section: 0)]
            XCTAssertEqual(article.url, articleJson.web_url)
            XCTAssertEqual(article.id, articleJson._id)
            XCTAssertEqual(article.date, articleJson.pub_date)
            XCTAssertEqual(article.snippet, articleJson.snippet)
            XCTAssertEqual(article.source, articleJson.source)
            
            expectation.fulfill()
        }
        
        viewModel.reload()
        wait(for: [expectation], timeout: 10)
    }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, _  in }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private func clearContainer() {
        container.viewContext.performAndWait {
            let request = NSFetchRequest<Article>(entityName: "\(Article.self)")
            try? container.viewContext.fetch(request).forEach(container.viewContext.delete)
        }
    }
    
}
