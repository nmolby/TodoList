//
//  TodoItemRepositoryImp.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation
import CoreData

class TodoItemRepositoryImp: TodoItemRepository {

    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func getTodoItems() async throws -> [TodoItem] {
        let context = coreDataManager.container.viewContext
        
        return try await context.perform {
            let request = NSFetchRequest<TodoItem>(entityName: .todoItem)
            return try context.fetch(request)
        }
    }
    
    func deleteTodoItems(_ items: [TodoItem]) async throws {
        let context = coreDataManager.container.viewContext
        
        return try await context.perform {
            let fetchRequest = TodoItem.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
            
            fetchRequest.predicate = NSPredicate(format: "id IN %@", items.map(\.id))
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.executeAndMergeChanges(using: deleteRequest)
        }
    }
}
