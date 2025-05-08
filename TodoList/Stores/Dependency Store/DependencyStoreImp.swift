//
//  DependencyStoreImp.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

@Observable class DependencyStoreImp: DependencyStore {
    
    var errorStore: any ErrorStore
    
    var todoItemRepository: any TodoItemRepository
    
    @MainActor init() {
        self.errorStore = ErrorStoreImp()
        
        let apiClient = APIClientImp(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
        let coreDataManager = CoreDataManager()
        
        self.todoItemRepository = TodoItemRepositoryImp(coreDataManager: coreDataManager, apiClient: apiClient)
    }
}
