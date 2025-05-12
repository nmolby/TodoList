//
//  TodoItemRepositoryMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation
@testable import TodoList

class TodoItemRepositoryMock: TodoItemRepositoryProtocol {
    
    var todoItems: [TodoItem] = []
    
    var refreshItemsHelper: (() async throws -> Void)? = nil

    func refreshTodoItems() async throws {
        guard let refreshItemsHelper else {
            throw TestError.responseNotSet
        }
        try await refreshItemsHelper()
    }

    var loadInitialItemsHelper: (() throws -> Void)? = nil
    
    @MainActor
    func loadInitialItems() throws {
        guard let loadInitialItemsHelper else {
            throw TestError.responseNotSet
        }
        try loadInitialItemsHelper()
    }

    var deleteTodoItemsHelper: (([TodoItem]) async throws -> Void)? = nil

    func deleteTodoItems(_ items: [TodoItem]) async throws {
        guard let deleteTodoItemsHelper else {
            throw TestError.responseNotSet
        }
        try await deleteTodoItemsHelper(items)
    }

    var addTodoHelper: ((TodoItem) async throws -> Void)? = nil

    func addTodo(_ item: TodoItem) async throws {
        guard let addTodoHelper else {
            throw TestError.responseNotSet
        }
        try await addTodoHelper(item)
    }
    
    var loadSampleTodosHelper: (() async throws -> Void)? = nil

    func loadSampleTodos() async throws {
        guard let loadSampleTodosHelper else {
            throw TestError.responseNotSet
        }
        try await loadSampleTodosHelper()
    }
    

}
