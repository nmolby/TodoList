//
//  TodoItemRepository.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

protocol TodoItemRepository {
    func refreshTodoItems() async throws
    @MainActor func loadInitialItems() throws
    func deleteTodoItems(_ items: [TodoItem]) async throws
    func addTodo(_ item: TodoItem) async throws
    func loadSampleTodos() async throws
    
    var todoItems: [TodoItem] { get }
}

extension TodoItemRepository {
    func deleteTodoItem(_ item: TodoItem) async throws {
        try await deleteTodoItems([item])
    }
}
