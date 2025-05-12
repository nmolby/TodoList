//
//  TodoItemRepositoryTests.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/9/25.
//

import Testing
import CoreData
@testable import TodoList

@MainActor struct TodoItemRepositoryTests {

    @Test("Test loading pulls items from core data and converts them")
    func testLoadInitialItems() throws {
        let sut = constructSUT()
        
        let entities = createMockEntities(context: sut.coreDataManager.container.viewContext)
        
        try sut.repository.loadInitialItems()
        
        #expect(Set(sut.repository.todoItems.map(\.id)) == Set(entities.map(\.id)))
    }
    
    @Test("Test refreshTodoItems pulls items from core data and converts them")
    func testRefreshTodoItems() async throws {
        let sut = constructSUT()
        
        let entities = createMockEntities(context: sut.coreDataManager.container.viewContext)
        
        try await sut.repository.refreshTodoItems()
        
        #expect(Set(sut.repository.todoItems.map(\.id)) == Set(entities.map(\.id)))
    }
    
    @Test("Test addTodo adds todo correctly")
    func testAddTodo() async throws {
        let sut = constructSUT()
        
        let todo = TodoItem(name: "Test Todo", id: UUID().uuidString, creationDate: .now)
        
        try await sut.repository.addTodo(todo)
        
        #expect(sut.repository.todoItems == [todo])
    }
    
    @Test("Test loadSampleTodos happy path")
    func testLoadSampleTodos_happyPath() async throws {
        let sut = constructSUT()
        
        let mockDTOs = createMockDTOs()
        
        sut.apiClient.requestHelper = { route in
            #expect(route == .fetchTodos)
            return mockDTOs
        }
        
        try await sut.repository.loadSampleTodos()
        
        #expect(Set(sut.repository.todoItems.map(\.id)) == Set(mockDTOs.map { String($0.id) }))
    }
    
    @Test("Test loadSampleTodos error is propogated")
    func testLoadSampleTodos_error() async throws {
        let sut = constructSUT()
        let error = TestError.uniqueTestError(.init())
                
        sut.apiClient.requestHelper = { route in
            throw error
        }
        
        await #expect(throws: error) {
            try await sut.repository.loadSampleTodos()
        }
        
    }

    
    private func constructSUT() -> SUT {
        let coreDataManager = CoreDataManager(inMemory: true)
        let apiClient = APIClientMock<[TodoItemDTO]>()
        let repository = TodoItemRepository(coreDataManager: coreDataManager, apiClient: apiClient)
        
        return SUT(repository: repository, coreDataManager: coreDataManager, apiClient: apiClient)
    }
    
    private struct SUT {
        var repository: TodoItemRepository
        var coreDataManager: CoreDataManager
        var apiClient: APIClientMock<[TodoItemDTO]>
    }

}

extension TodoItemRepositoryTests {
    private func createMockEntities(context: NSManagedObjectContext) -> [TodoItemEntity] {
        return [
            TodoItemEntity(context: context, name: "Feed the dog", id: "1", creationDate: Date()),
            TodoItemEntity(context: context, name: "Take out trash", id: "2", creationDate: Date().addingTimeInterval(-3600)),
            TodoItemEntity(context: context, name: "Read Bible", id: "3", creationDate: Date().addingTimeInterval(-7200)),
            TodoItemEntity(context: context, name: "Water plants", id: "4", creationDate: Date().addingTimeInterval(-10800)),
            TodoItemEntity(context: context, name: "Reply to email", id: "5", creationDate: Date().addingTimeInterval(-14400)),
            TodoItemEntity(context: context, name: "Buy groceries", id: "6", creationDate: Date().addingTimeInterval(-18000)),
            TodoItemEntity(context: context, name: "Call Mom", id: "7", creationDate: Date().addingTimeInterval(-21600)),
            TodoItemEntity(context: context, name: "Go for a walk", id: "8", creationDate: Date().addingTimeInterval(-25200)),
            TodoItemEntity(context: context, name: "Check mailbox", id: "9", creationDate: Date().addingTimeInterval(-28800)),
            TodoItemEntity(context: context, name: "Make dinner", id: "10", creationDate: Date().addingTimeInterval(-32400))
        ]

    }
    
    private func createMockDTOs() -> [TodoItemDTO] {
        return [
            TodoItemDTO(userId: 1, id: 1, title: "Feed the dog", completed: false),
            TodoItemDTO(userId: 1, id: 2, title: "Take out trash", completed: true),
            TodoItemDTO(userId: 1, id: 3, title: "Read Bible", completed: false),
            TodoItemDTO(userId: 1, id: 4, title: "Water plants", completed: true),
            TodoItemDTO(userId: 1, id: 5, title: "Reply to email", completed: false),
            TodoItemDTO(userId: 1, id: 6, title: "Buy groceries", completed: true),
            TodoItemDTO(userId: 1, id: 7, title: "Call Mom", completed: false),
            TodoItemDTO(userId: 1, id: 8, title: "Go for a walk", completed: true),
            TodoItemDTO(userId: 1, id: 9, title: "Check mailbox", completed: false),
            TodoItemDTO(userId: 1, id: 10, title: "Make dinner", completed: true)
        ]
    }

}
