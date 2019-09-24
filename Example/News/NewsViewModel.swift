//
//  NewsViewModel.swift
//  Example
//
//  Created by Alex Belozierov on 8/25/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData
import CoreDataJsonParser

protocol NewsViewModelDelegate: FetchControllerDelegate {
    
    func loadBegins()
    func loadEnds()
    func recieveError(_ error: Error)
    
}

class NewsViewModel: DataSourceContainer {
    
    typealias Item = Article
    
    let viewContext: NSManagedObjectContext
    let parseContext: NSManagedObjectContext
    let newsApiService: NewsApiService?
    
    weak var delegate: NewsViewModelDelegate? {
        didSet { dataSource.delegate = delegate }
    }
    
    init(newsApiService: NewsApiService? = NYTimesService.shared, viewContext: NSManagedObjectContext = .view, parseContext: NSManagedObjectContext = .background) {
        self.newsApiService = newsApiService
        self.viewContext = viewContext
        self.parseContext = parseContext
    }
    
    func reload() {
        paginator.loadNextPage()
    }
    
    private func catchError(closure: () throws -> Void) {
        do { try closure() }
        catch { DispatchQueue.main.async { self.delegate?.recieveError(error) } }
    }
    
    // MARK: - FetchController
    
    lazy var dataSource: FetchController<Item> = {
        let request = NSFetchRequest<Item>(entityName: "\(Item.self)")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Article.date, ascending: false)]
        return FetchController(request: request, context: viewContext, section: \.sectionIndex)
    }()
    
    // MARK: - Paginator
    
    private lazy var paginator = Paginator<ArticlePageData> {
        [unowned self] in self.load(page: $0.page)
    }
    
    func willShowItem(at indexPath: IndexPath) {
        paginator.prepareForItem(at: itemIndex(for: indexPath))
    }
    
    // MARK: - Request
    
    private func load(page: Int) {
        delegate?.loadBegins()
        newsApiService?.getNews(search: "ukraine", page: page) { [weak self] result in
            DispatchQueue.main.async { self?.completeLoad(with: result) }
        }
    }
    
    private func completeLoad(with result: Result<Json, Error>) {
        delegate?.loadEnds()
        catchError {
            try paginator.update(with: result)
            try parseArticles(json: (result.get().response?.docs).tryMap { $0 })
        }
    }
    
    // MARK: - Parse Articles
    
    private func parseArticles(json: Json) {
        parseContext.perform {
            self.catchError {
                try json.decode(type: [Article].self, context: self.parseContext)
                try self.parseContext.save()
            }
        }
    }
    
}
