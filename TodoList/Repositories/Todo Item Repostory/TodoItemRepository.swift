//
//  TodoItemRepository.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

protocol TodoItemRepository {
    func getTodoItems() async throws -> [TodoItem]
    func deleteTodoItems(_ items: [TodoItem]) async throws
    func deleteAllTodoItems() async throws
}

extension TodoItemRepository {
    func deleteTodoItem(_ item: TodoItem) async throws {
        try await deleteTodoItems([item])
    }
}
