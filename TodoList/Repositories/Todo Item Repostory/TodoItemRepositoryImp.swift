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
    let apiClient: any APIClient
    
    init(coreDataManager: CoreDataManager, apiClient: any APIClient) {
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
        let todoDtos: [TodoItemDTO] = try await apiClient.request(.fetchTodos)
        
        // To facilitate loading sample todos multiple times, override the id on the todos if already present in the list
        let todoItemsIdSet = Set(todoItems.map(\.id))
        let todoItemDtoIdSet = Set(todoDtos.map { String($0.id) })
        let intersection = todoItemsIdSet.intersection(todoItemDtoIdSet)
        
        let overrideId = !intersection.isEmpty
        
        let context = coreDataManager.container.viewContext

        try await context.perform {
            _ = todoDtos.map { dto in
                let id = overrideId ? UUID().uuidString : String(dto.id)
                return TodoItemEntity(context: context, name: dto.title, id: String(id), creationDate: .now)
            }
            
            try context.save()
        }

        try await refreshTodoItems()
    }
    
    var todoItems: [TodoItem] = []
}

extension TodoItemRepositoryImp {
    @MainActor static var preview: TodoItemRepositoryImp {
        TodoItemRepositoryImp(coreDataManager: .preview, apiClient: APIClientImp.preview)
    }
}
