//
//  IndexPathUpdate.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

enum IndexPathUpdate: Hashable {
    case insertItems(at: [IndexPath])
    case deleteItems(at: [IndexPath])
    case updateItems(at: [IndexPath])
    case moveItem(from: IndexPath, to: IndexPath)
    case insertSection(at: IndexSet)
    case deleteSection(at: IndexSet)
    case updateSection(at: IndexSet)
}
