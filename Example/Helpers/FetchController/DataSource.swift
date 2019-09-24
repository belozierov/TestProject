//
//  DataSource.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

protocol DataSource {
    
    associatedtype Item
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    subscript(indexPath: IndexPath) -> Item { get }
    subscript(item: Item) -> IndexPath? { get }
    var items: [[Item]] { get }
    var count: Int { get }
    var isEmpty: Bool { get }
    
}

extension DataSource {
    
    var isEmpty: Bool {
        numberOfSections == 0
    }
    
    func itemIndex(for indexPath: IndexPath) -> Int {
        (0..<indexPath.section).map(numberOfRows).reduce(0, +) + indexPath.row
    }
    
}

protocol DataSourceContainer: DataSource {
    
    associatedtype Source: DataSource where Source.Item == Item
    var dataSource: Source { get }
    
}

extension DataSourceContainer {
    
    var numberOfSections: Int { dataSource.numberOfSections }
    func numberOfRows(in section: Int) -> Int { dataSource.numberOfRows(in: section) }
    subscript(indexPath: IndexPath) -> Item { dataSource[indexPath] }
    subscript(item: Item) -> IndexPath? { dataSource[item] }
    var items: [[Item]] { dataSource.items }
    var count: Int { dataSource.count }
    var isEmpty: Bool { dataSource.isEmpty }
    
}
