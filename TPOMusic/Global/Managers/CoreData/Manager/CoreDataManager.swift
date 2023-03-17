//
//  CoreDataManager.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/17.
//

import Foundation
import CoreData

class CoreDataManager {

    // MARK: - Properties
    var container: NSPersistentContainer?

    var mainContext: NSManagedObjectContext {
        guard let context = container?.viewContext else {
            fatalError()
        }
        return context
    }


    // MARK: - Func
    func setup(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        container?.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError(error.localizedDescription) }
        })
    }

    func saveMainContext() {
        mainContext.perform {
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                } catch { print(error) }
            }
        }
    }
}
