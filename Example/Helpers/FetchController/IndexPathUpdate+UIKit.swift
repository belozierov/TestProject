//
//  IndexPathUpdate+UIKit.swift
//  Example
//
//  Created by Alex Belozierov on 8/26/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import UIKit

extension UITableView {
    
    func update(with changes: [IndexPathUpdate]) {
        beginUpdates()
        changes.forEach(update)
        endUpdates()
    }
    
    private func update(with change: IndexPathUpdate) {
        switch change {
        case .insertItems(let indexPaths):
            insertRows(at: indexPaths, with: .automatic)
        case .deleteItems(let indexPaths):
            deleteRows(at: indexPaths, with: .automatic)
        case .updateItems(let indexPaths):
            reloadRows(at: indexPaths, with: .none)
        case .moveItem(let fromIdexPath, let toIndexPath):
            moveRow(at: fromIdexPath, to: toIndexPath)
        case .insertSection(let indexSet):
            insertSections(indexSet, with: .none)
        case .deleteSection(let indexSet):
            deleteSections(indexSet, with: .none)
        case .updateSection(let indexSet):
            reloadSections(indexSet, with: .none)
        }
    }
    
}
