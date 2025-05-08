//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation
import SwiftUI

@MainActor @Observable class TodoListViewModel {
    let repository: any TodoItemRepository
    var errorStore: any ErrorStore
    
    var viewState: TodoListViewState {
        if !firstLoadFinished {
            return .loading
        } else if repository.todoItems.isEmpty {
            return .empty
        } else {
            return .loaded(items: repository.todoItems)
        }
    }
    
    var firstLoadFinished: Bool = false
    var addingNewTodoItem: Bool = false

    var selectedItems = Set<String>()
    var editMode = EditMode.inactive
    
    init(repository: any TodoItemRepository, errorStore: any ErrorStore) {
        self.repository = repository
        self.errorStore = errorStore
    }
    
    // MARK: Computed Properties
    
    var allSelected: Bool {
        guard case .loaded(let items) = viewState else {
            return false
        }
        
        return selectedItems.count == items.count
    }
    
    // MARK: Mutating global state
    
    func refreshItems() async {
        defer {
            firstLoadFinished = true
        }
        
        do {
            try await repository.refreshTodoItems()
        } catch {
            errorStore.errorString = "Loading to-dos failed. Please try again."
        }
        
    }
    
    func deleteItems(at offsets: IndexSet) async {
        guard case .loaded(let allItems) = viewState, !offsets.isEmpty else {
            return
        }
                
        let itemsToDelete = offsets.map { allItems[$0] }
        
        do {
            try await repository.deleteTodoItems(itemsToDelete)
        } catch {
            errorStore.errorString = "Deleting to-dos failed. Please try again."
        }
    }
    
    func deleteSelectedItems() async {
        guard case .loaded(let items) = viewState, !selectedItems.isEmpty else {
            return
        }

        let itemsToDelete = items.filter {
            selectedItems.contains($0.id)
        }
        
        do {
            try await repository.deleteTodoItems(itemsToDelete)
            
            editMode = .inactive
        } catch {
            errorStore.errorString = "Deleting to-dos failed. Please try again."
        }
    }
    
    // MARK: Mutating local state
    
    func toggleEditing() {
        editMode = editMode.isEditing ? .inactive : .active
    }
    
    func selectAll() {
        guard case .loaded(let items) = viewState else {
            return
        }

        selectedItems = Set(items.map(\.id))
    }
    
    func deselectAll() {
        selectedItems.removeAll()
    }
    
    func addNewTodoItem() {
        addingNewTodoItem = true
    }
    
    func createAddNewTodoItemViewModel() -> AddTodoItemViewModel {
        return .init(todoItemRepository: repository, errorStore: errorStore)
    }
}
