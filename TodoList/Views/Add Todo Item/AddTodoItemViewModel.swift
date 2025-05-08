//
//  AddTodoItemViewModel.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import Foundation

@Observable class AddTodoItemViewModel {
    let todoItemRepository: TodoItemRepository
    var errorStore: ErrorStore
    
    var name: String = ""
    var submitting: Bool = false
    
    init(todoItemRepository: TodoItemRepository, errorStore: ErrorStore) {
        self.todoItemRepository = todoItemRepository
        self.errorStore = errorStore
    }
    
    func save() async {
        submitting = true
        defer {
            submitting = false
        }
        
        let itemToSave = TodoItem(name: name)
        do {
            try await todoItemRepository.addTodo(itemToSave)
        } catch {
            errorStore.errorString = "Error saving your todo. Please try again later."
        }
    }
}
