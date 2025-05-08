//
//  TodoItemRepositoryMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation
@testable import TodoList

class TodoItemRepositoryMock: TodoItemRepository {
    var refreshItemsHelper: (() async throws -> Void)? = nil

    func refreshTodoItems() async throws {
        guard let refreshItemsHelper else {
            throw TestError.responseNotSet
        }
        
        try await refreshTodoItems()
    }
    
    var deleteTodoItemsHelper: (([TodoList.TodoItem]) async throws -> Void)? = nil

    func deleteTodoItems(_ items: [TodoList.TodoItem]) async throws {
        guard let deleteTodoItemsHelper else {
            throw TestError.responseNotSet
        }
        
        return try await deleteTodoItemsHelper(items)
    }
        
    var todoItems: [TodoList.TodoItem] = []
}
