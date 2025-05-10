//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation
import SwiftUI

@MainActor @Observable class TodoListViewModel {
    let repository: any TodoItemRepositoryProtocol
    var errorStore: any ErrorStoreProtocol
    var navigationRouter: any NavigationRouterProtocol<BaseAppNavigationRoute>
        
    var sortMethod = SortMethod.newestFirst
    var selectedItems = Set<String>()
    var editMode = EditMode.inactive
    
    private var firstLoadFinished: Bool = false
    
    init(repository: any TodoItemRepositoryProtocol, errorStore: any ErrorStoreProtocol, navigationRouter: any NavigationRouterProtocol<BaseAppNavigationRoute>) {
        self.repository = repository
        self.errorStore = errorStore
        self.navigationRouter = navigationRouter
    }
    
    // MARK: Computed Properties
    
    var viewState: TodoListViewState {
        if !firstLoadFinished {
            return .loading
        } else if repository.todoItems.isEmpty {
            return .empty
        } else {
            return .loaded(items: sort(items: repository.todoItems))
        }
    }
    
    var allSelected: Bool {
        guard case .loaded(let items) = viewState else {
            return false
        }
        
        return selectedItems == Set(items.map(\.id))
    }
    
    var shouldShowEditButton: Bool {
        switch viewState {
        case .loading, .empty:
            return false
        case .loaded:
            return true
        }
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
    
    func loadSampleTodos() async {
        do {
            try await repository.loadSampleTodos()
        } catch {
            errorStore.errorString = "Loading sample to-dos failed. Please try again."
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
        navigationRouter.navigate(to: .addTodo)
    }
    
    func sort(items: [TodoItem]) -> [TodoItem] {
        switch sortMethod {
        case .newestFirst:
            return items.sorted {
                $0.creationDate > $1.creationDate
            }
        case .oldestFirst:
            return items.sorted {
                $0.creationDate < $1.creationDate
            }
        case .alphabeticalDescending:
            return items.sorted {
                $0.name.compare($1.name, options: .caseInsensitive) == .orderedDescending
            }
        case .alphabeticalAscending:
            return items.sorted {
                $0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending
            }
        }
    }
}
