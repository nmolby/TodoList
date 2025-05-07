//
//  TodoItemRepositoryMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation
import TodoList

class TodoItemRepositoryMock: TodoItemRepository {
    
    var getTodoItemsHelper: (() async throws -> [TodoList.TodoItem])? = nil
    
    func getTodoItems() async throws -> [TodoList.TodoItem] {
        guard let getTodoItemsHelper else {
            throw TestError.responseNotSet
        }
        
        return try await getTodoItemsHelper()
    }
    
    var deleteTodoItemsHelper: (([TodoList.TodoItem]) async throws -> Void)? = nil
    
    func deleteTodoItems(_ items: [TodoList.TodoItem]) async throws {
        guard let deleteTodoItemsHelper else {
            throw TestError.responseNotSet
        }
        
        return try await deleteTodoItemsHelper(items)
    }
    
    
}
