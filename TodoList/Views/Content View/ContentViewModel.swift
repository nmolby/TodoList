//
//  ContentViewModel.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation

@Observable @MainActor class ContentViewModel {
    var errorStore: any ErrorStoreProtocol
    var todoItemRepository: any TodoItemRepositoryProtocol
    
    var navigationRouter: BaseAppNavigationRouter
    
    init(errorStore: any ErrorStoreProtocol, todoItemRepository: any TodoItemRepositoryProtocol, navigationRouter: BaseAppNavigationRouter) {
        self.errorStore = errorStore
        self.todoItemRepository = todoItemRepository
        self.navigationRouter = navigationRouter
    }
    
    var errorString: String? {
        errorStore.errorString
    }
    
    func handleOnAppear() {
        do {
            try todoItemRepository.loadInitialItems()
        } catch {
            errorStore.errorString = "Something went wrong loading your todos. Try again later."
        }
    }
    
    func createAddTodoItemViewModel() -> AddTodoItemViewModel {
        return .init(todoItemRepository: todoItemRepository, errorStore: errorStore)
    }
    
    func createTodoListViewModel() -> TodoListViewModel {
        return .init(repository: todoItemRepository, errorStore: errorStore, navigationRouter: navigationRouter)
    }
    
}
