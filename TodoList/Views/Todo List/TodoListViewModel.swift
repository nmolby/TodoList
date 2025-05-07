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

    var viewState = TodoListViewState.loading
    var selectedItems = Set<String>()
    var editMode = EditMode.inactive
    
    init(repository: TodoItemRepository) {
        self.repository = repository
    }
    
    var allSelected: Bool {
        guard case .loaded(let items) = viewState else {
            return false
        }
        
        return selectedItems.count == items.count
    }
    
    func loadTodoItems() async {
        do {
            let items = try await repository.getTodoItems().sorted { item1, item2 in
                return item1.creationDate < item2.creationDate
            }
            viewState = .loaded(items: items)
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteItems(at offsets: IndexSet) async throws {
        guard case .loaded(let allItems) = viewState, !offsets.isEmpty else {
            return
        }
                
        let itemsToDelete = offsets.map { allItems[$0] }
        
        try await repository.deleteTodoItems(itemsToDelete)

        await loadTodoItems()
    }
    
    func deleteSelectedItems() async throws {
        guard case .loaded(let items) = viewState, !selectedItems.isEmpty else {
            return
        }

        let todoItems = items.filter {
            selectedItems.contains($0.id)
        }
        
        try await repository.deleteTodoItems(todoItems)
        
        await loadTodoItems()
    }
    
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
}
