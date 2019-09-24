//
//  CoreDataStack.swift
//  Example
//
//  Created by Alex Belozierov on 8/24/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    static let view = NSPersistentContainer.shared.viewContext
    static let background = NSPersistentContainer.shared.newBackgroundContext()
    
}

extension NSPersistentContainer {
    
    fileprivate static let shared: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, _  in }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
}
