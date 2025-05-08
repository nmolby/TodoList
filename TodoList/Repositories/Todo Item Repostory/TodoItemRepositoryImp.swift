//
//  TodoItemRepositoryImp.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation
import CoreData
import SwiftUI

@Observable
class TodoItemRepositoryImp: TodoItemRepository {
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        
        Task {
            try? await refreshTodoItems()
        }
    }
    
    func refreshTodoItems() async throws {
        let context = coreDataManager.container.viewContext
        
        todoItems = try await context.perform {
            let request = NSFetchRequest<TodoItemEntity>(entityName: .todoItem)
            return try context.fetch(request)
        }.map { entity in
            entity.toTodoItem()
        }
    }
    
    func deleteTodoItems(_ items: [TodoItem]) async throws {
        let context = coreDataManager.container.viewContext
        
        try await context.perform {
            let fetchRequest = TodoItemEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
            
            fetchRequest.predicate = NSPredicate(format: "id IN %@", items.map(\.id))
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.executeAndMergeChanges(using: deleteRequest)
        }
        
        try await refreshTodoItems()
    }
    
    func addTodo(_ item: TodoItem) async throws {
        let context = coreDataManager.container.viewContext

        try await context.perform {
            _ = TodoItemEntity(
                context: context,
                name: item.name,
                id: item.id,
                creationDate: item.creationDate,
                editDate: item.editDate
            )
            
            try context.save()
        }

        try await refreshTodoItems()
    }
    
    
    var todoItems: [TodoItem] = []
}
