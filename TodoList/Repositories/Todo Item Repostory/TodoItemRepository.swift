//
//  TodoItemRepository.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation
import CoreData
import SwiftUI

@Observable
class TodoItemRepository: TodoItemRepositoryProtocol {
    let coreDataManager: CoreDataManager
    let apiClient: any APIClientProtocol
    
    var todoItems: [TodoItem] = []
    
    init(coreDataManager: CoreDataManager, apiClient: any APIClientProtocol) {
        self.coreDataManager = coreDataManager
        self.apiClient = apiClient
    }
    
    @MainActor func loadInitialItems() throws {
        let context = coreDataManager.container.viewContext
        
        let request = NSFetchRequest<TodoItemEntity>(entityName: .todoItem)
        todoItems = try context.fetch(request).map { entity in
            entity.toTodoItem()
        }
    }
    
    func refreshTodoItems() async throws {
        let context = coreDataManager.container.viewContext
        
        todoItems = try await context.perform {
            let request = NSFetchRequest<TodoItemEntity>(entityName: .todoItem)
            return try context.fetch(request).map { entity in
                entity.toTodoItem()
            }
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
    
    @MainActor func loadSampleTodos() async throws {
        let context = coreDataManager.container.viewContext

        let todoDtos: [TodoItemDTO] = try await apiClient.request(.fetchTodos)
        
        try await context.perform {
            // Remove Todo's that will be replaced
            let fetchRequest = TodoItemEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
            
            fetchRequest.predicate = NSPredicate(format: "id IN %@", todoDtos.map(\.id))
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.executeAndMergeChanges(using: deleteRequest)
            
            // Add in new Todo's to replace them
            _ = todoDtos.map { dto in
                return TodoItemEntity(context: context, name: dto.title, id: String(dto.id), creationDate: .now)
            }
            
            try context.save()
        }
        
        try await refreshTodoItems()
    }
    
}

extension TodoItemRepository {
    @MainActor static var preview: TodoItemRepository {
        TodoItemRepository(coreDataManager: .preview, apiClient: APIClient.preview)
    }
}
