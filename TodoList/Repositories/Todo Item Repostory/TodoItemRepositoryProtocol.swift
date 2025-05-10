//
//  TodoItemRepositoryProtocol.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

protocol TodoItemRepositoryProtocol {
    func refreshTodoItems() async throws
    @MainActor func loadInitialItems() throws
    func deleteTodoItems(_ items: [TodoItem]) async throws
    func addTodo(_ item: TodoItem) async throws
    func loadSampleTodos() async throws
    
    var todoItems: [TodoItem] { get }
}

extension TodoItemRepositoryProtocol {
    func deleteTodoItem(_ item: TodoItem) async throws {
        try await deleteTodoItems([item])
    }
}
