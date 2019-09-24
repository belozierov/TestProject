//
//  Paginator.swift
//  Example
//
//  Created by Alex Belozierov on 8/22/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

class Paginator<T: PaginatorPageData> {
    
    typealias LoadResult = Result<T.InitData, Error>
    typealias UpdateResult = Result<Update, Error>
    typealias PageLoadData = (data: T?, page: Int, completion: (LoadResult) -> Void)
    struct Update { let old: T?, new: T }
    
    var nextPage = 0
    var data: T?
    var prefetching: Int
    var isLoading = false
    var nextPageLoader: (PageLoadData) -> Void
    var updateHandler: ((UpdateResult) -> Void)?
    
    init(prefetching: Int = 4, nextPageLoader: @escaping (PageLoadData) -> Void) {
        self.prefetching = prefetching
        self.nextPageLoader = nextPageLoader
    }
    
    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        nextPageLoader((data, nextPage, { [weak self] in _ = try? self?.update(with: $0) }))
    }
    
    func prepareForItem(at index: Int) {
        guard !isLoading, let data = data, !data.isLast,
            index > data.loaded - prefetching else { return }
        loadNextPage()
    }
    
    @discardableResult
    func update(with result: LoadResult) throws -> Update {
        switch result {
        case .success(let data):
            return try update(with: data)
        case .failure(let error):
            isLoading = false
            updateHandler?(.failure(error))
            throw error
        }
    }
    
    @discardableResult
    func update(with data: T.InitData) throws -> Update {
        do {
            let page = try T(previous: self.data, data: data)
            return update(with: page)
        } catch {
            isLoading = false
            updateHandler?(.failure(error))
            throw error
        }
    }
    
    @discardableResult
    func update(with page: T) -> Update {
        nextPage += 1
        isLoading = false
        let old = self.data
        self.data = page
        let update = Update(old: old, new: page)
        updateHandler?(.success(update))
        return update
    }
    
    func reset() {
        nextPage = 0
        data = nil
        isLoading = false
    }
    
}

extension Paginator.Update {
    
    var newLoaded: Int {
        old.map { new.loaded - $0.loaded } ?? new.loaded
    }
    
    var isLastPage: Bool {
        new.isLast
    }
    
}
