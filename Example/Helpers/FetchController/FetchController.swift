//
//  FetchController.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

protocol FetchControllerDelegate: class {
    
    func dataDidUpdated(updates: [IndexPathUpdate])
    
}

class FetchController<T: NSManagedObject>: DataSource {
    
    private let controller: NSFetchedResultsController<T>
    private let controllerDelegate = FetchedResultsControllerDelegate()
    weak var delegate: FetchControllerDelegate?
    
    convenience
    init<N>(request: NSFetchRequest<T>, context: NSManagedObjectContext, section: KeyPath<T, N>) {
        let sectionName = NSExpression(forKeyPath: section).keyPath
        self.init(request: request, context: context, sectionName: sectionName)
    }
    
    init(request: NSFetchRequest<T>, context: NSManagedObjectContext, sectionName: String? = nil) {
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 50
        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionName, cacheName: nil)
        controller.delegate = controllerDelegate
        controllerDelegate.changeHandler = { [weak self] in self?.update(with: $0) }
        try? controller.performFetch()
    }
    
    var context: NSManagedObjectContext {
        controller.managedObjectContext
    }
    
    var request: NSFetchRequest<T> {
        controller.fetchRequest
    }
    
    private func update(with changes: [IndexPathUpdate]) {
        guard !changes.isEmpty else { return }
        delegate?.dataDidUpdated(updates: changes)
    }
    
    var numberOfSections: Int {
        sectionInfos.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        sectionInfos[section].numberOfObjects
    }
    
    subscript(indexPath: IndexPath) -> T {
        controller.object(at: indexPath)
    }
    
    subscript(item: T) -> IndexPath? {
        controller.indexPath(forObject: item)
    }
    
    var count: Int {
        controller.fetchedObjects?.count ?? 0
    }
    
    var items: [[T]] {
        sectionInfos.compactMap { $0.objects as? [T] }
    }
    
    private var sectionInfos: [NSFetchedResultsSectionInfo] {
        guard let sections = controller.sections else { return [] }
        return sections.compactMap { $0.numberOfObjects > 0 ? $0 : nil }
    }
    
}

private class FetchedResultsControllerDelegate: NSObject {
    
    private var updates = [IndexPathUpdate]()
    var changeHandler: (([IndexPathUpdate]) -> ())?
    
}

extension FetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.firstSectionIsEmpty { updates.append(.insertSection(at: .zero)) }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: updates.append(.insertSection(at: indexSet))
        case .delete: updates.append(.deleteSection(at: indexSet))
        case .update: updates.append(.updateSection(at: indexSet))
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .move, .update:
            guard let from = indexPath, let to = newIndexPath else { break }
            if from == to {
                updates.append(.updateItems(at: [from]))
            } else {
                updates.append(.deleteItems(at: [from]))
                updates.append(.insertItems(at: [to]))
            }
        case .insert:
            newIndexPath.map { updates.append(.insertItems(at: [$0])) }
        case .delete:
            indexPath.map { updates.append(.deleteItems(at: [$0])) }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.firstSectionIsEmpty { updates.append(.deleteSection(at: .zero)) }
        changeHandler?(updates)
        updates = []
    }
    
}

extension IndexSet {
    
    fileprivate static let zero = IndexSet(integer: 0)
    
}

extension NSFetchedResultsController where ResultType == NSFetchRequestResult {
    
    fileprivate var firstSectionIsEmpty: Bool {
        return sections?.first?.numberOfObjects == 0
    }
    
}
