//
//  TodoListViewModelTests.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Testing
import CoreData
@testable import TodoList

@MainActor struct TodoListViewModelTests {
    
    // MARK: Init
    @Test("Ensure properties are initialized correctly")
    func testInit() {
        let (viewModel, _, _) = constructSUT()
        
        #expect(viewModel.viewState == .loading)
        #expect(viewModel.selectedItems.isEmpty)
        #expect(viewModel.editMode == .inactive)
    }
    
    // MARK: Computed Properties
    @Test("Tells allSelected logic works")
    func testAllSelected() async throws {
        let (viewModel, _, coreDataManager) = constructSUT()
        
        let items = mockItems(context: coreDataManager.container.viewContext)
        
        viewModel.viewState = .loaded(items: items)
        viewModel.selectedItems = .init()
        
        #expect(viewModel.allSelected == false)
        
        viewModel.selectedItems = .init(items[0..<5].map(\.id))
        #expect(viewModel.allSelected == false)
        
        viewModel.selectedItems = .init(items.map(\.id))
        
        #expect(viewModel.allSelected == true)
    }
    
    // MARK: loadTodoItems
    @Test("Ensure loadTodoItems success leads to view state loaded")
    func testLoadTodoItems_happyPath() async {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let mockItems = mockItems(context: coreDataManager.container.viewContext)
        
        mockRepo.getTodoItemsHelper = {
            return mockItems
        }
        
        await viewModel.loadTodoItems()
                        
        #expect(viewModel.viewState == .loaded(items: mockItems))
        
        let itemsIncorrectlySorted = mockItems.sorted { item1, item2 in
            return item1.creationDate > item2.creationDate
        }
        
        #expect(viewModel.viewState != .loaded(items: itemsIncorrectlySorted))
    }
    
    @Test("Ensure loadTodoItems error leads to view state error")
    func testLoadTodoItems_errorPath() async {
        let (viewModel, mockRepo, _) = constructSUT()
        
        let expectedError = TestError.uniqueTestError(.init())
        
        mockRepo.getTodoItemsHelper = {
            throw expectedError
        }
        
        await viewModel.loadTodoItems()
        
        #expect(viewModel.viewState == .error(expectedError))
    }
    
    // MARK: deleteItems
    
    @Test("Ensure delete items deletes correct items and re-fetches")
    func testDeleteItems_happyPath() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
        let itemsAfterDeletions = Array(allItems[0..<5])
        let itemsToBeDeleted = Array(allItems[5...])
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        var deleteTodoItemCallCount = 0
        
        await viewModel.loadTodoItems()
        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            #expect(Set(deletedItems) == Set(itemsToBeDeleted))
            deleteTodoItemCallCount += 1
        }
        
        mockRepo.getTodoItemsHelper = {
            return itemsAfterDeletions
        }
        
        try await viewModel.deleteItems(at: .init(integersIn: 5..<allItems.endIndex))
                
        #expect(viewModel.viewState == .loaded(items: itemsAfterDeletions))
        #expect(deleteTodoItemCallCount == 1)
    }
    
    @Test("Ensure delete items no-op when input is empty")
    func testDeleteItems_emptyPath() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        await viewModel.loadTodoItems()
                        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            Issue.record("Delete items should not be called")
        }
        
        mockRepo.getTodoItemsHelper = {
            Issue.record("Get items should not be called")
            return []
        }
        
        try await viewModel.deleteItems(at: .init())
    }
    
    @Test("Ensure delete items error is propogated")
    func testDeleteItems_error() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
        let expectedError = TestError.uniqueTestError(.init())
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        mockRepo.deleteTodoItemsHelper = { _ in
            throw expectedError
        }
        
        await viewModel.loadTodoItems()
        
        await #expect(throws: expectedError) {
            try await viewModel.deleteItems(at: .init(integersIn: 5..<allItems.endIndex))
        }
    }
    
    // MARK: deleteSelectedItems
    
    @Test("Ensure delete selected item deletes selected items and re-fetches")
    func testDeleteSelectedItems_happyPath() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
        let itemsAfterDeletions = Array(allItems[0..<5])
        let itemsToBeDeleted = Array(allItems[5...])
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        await viewModel.loadTodoItems()
        
        var deleteTodoItemCallCount = 0
        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            deleteTodoItemCallCount += 1
            #expect(Set(deletedItems) == Set(itemsToBeDeleted))
        }
        
        mockRepo.getTodoItemsHelper = {
            return itemsAfterDeletions
        }
        
        viewModel.selectedItems = Set(itemsToBeDeleted.map(\.id))
        try await viewModel.deleteSelectedItems()
                
        #expect(viewModel.viewState == .loaded(items: itemsAfterDeletions))
        #expect(deleteTodoItemCallCount == 1)
    }
    
    @Test("Ensure delete selected item no-op when selection is empty")
    func testDeleteSelectedItems_emptyPath() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        await viewModel.loadTodoItems()
        
        viewModel.selectedItems = .init()
                
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            Issue.record("Delete items should not be called")
        }
        
        mockRepo.getTodoItemsHelper = {
            Issue.record("Get items should not be called")
            return []
        }
        
        try await viewModel.deleteSelectedItems()
    }
    
    @Test("Ensure delete selected items error is propogated")
    func testDeleteSelectedItems_error() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
        let expectedError = TestError.uniqueTestError(.init())
                
        mockRepo.getTodoItemsHelper = {
            return allItems
        }
        
        mockRepo.deleteTodoItemsHelper = { _ in
            throw expectedError
        }
        
        await viewModel.loadTodoItems()
        
        viewModel.selectedItems = Set(allItems.map(\.id))
        
        await #expect(throws: expectedError) {
            try await viewModel.deleteSelectedItems()
        }
    }
    
    // MARK: toggleEditing
    @Test("Ensure toggle editing toggles editMode")
    func testToggleEditing() {
        let (viewModel, _, _) = constructSUT()
        
        viewModel.editMode = .inactive
        
        viewModel.toggleEditing()
        
        #expect(viewModel.editMode == .active)
        
        viewModel.toggleEditing()
        
        #expect(viewModel.editMode == .inactive)
    }
    
    // MARK: Select All
    @Test("Ensure select all selects all items")
    func testSelectAll() {
        let (viewModel, _, coreDataManager) = constructSUT()
        
        let items = mockItems(context: coreDataManager.container.viewContext)
        
        viewModel.viewState = .loaded(items: items)
        
        viewModel.selectAll()
        
        #expect(viewModel.selectedItems == Set(items.map(\.id)))
    }
    
    // MARK: Deselect All
    @Test("Ensure deselect all selects all items")
    func testDeselectAll() {
        let (viewModel, _, coreDataManager) = constructSUT()
        
        let items = mockItems(context: coreDataManager.container.viewContext)
        
        viewModel.viewState = .loaded(items: items)
        viewModel.selectedItems = Set(items.map(\.id))
        
        viewModel.deselectAll()
        
        #expect(viewModel.selectedItems.isEmpty)
    }
    
    
    private func constructSUT() ->  (TodoListViewModel, TodoItemRepositoryMock, CoreDataManager) {
        let mockRepository = TodoItemRepositoryMock()
        
        let viewModel = TodoListViewModel(repository: mockRepository)
        
        let coreDataManager = CoreDataManager.forUnitTests()
        
        return (viewModel, mockRepository, coreDataManager)
    }
    
}

extension TodoListViewModelTests {
    private func mockItems(context: NSManagedObjectContext) -> [TodoItem] {
        return [
            TodoItem(context: context, name: "Feed the dog", creationDate: Date(), complete: false, editDate: nil),
            TodoItem(context: context, name: "Take out trash", creationDate: Date().addingTimeInterval(-3600), complete: true, editDate: Date().addingTimeInterval(-1800)),
            TodoItem(context: context, name: "Read Bible", creationDate: Date().addingTimeInterval(-7200), complete: false, editDate: nil),
            TodoItem(context: context, name: "Water plants", creationDate: Date().addingTimeInterval(-10800), complete: true, editDate: Date().addingTimeInterval(-9000)),
            TodoItem(context: context, name: "Reply to email", creationDate: Date().addingTimeInterval(-14400), complete: false, editDate: nil),
            TodoItem(context: context, name: "Buy groceries", creationDate: Date().addingTimeInterval(-18000), complete: true, editDate: Date().addingTimeInterval(-10000)),
            TodoItem(context: context, name: "Call Mom", creationDate: Date().addingTimeInterval(-21600), complete: false, editDate: nil),
            TodoItem(context: context, name: "Go for a walk", creationDate: Date().addingTimeInterval(-25200), complete: true, editDate: Date().addingTimeInterval(-20000)),
            TodoItem(context: context, name: "Check mailbox", creationDate: Date().addingTimeInterval(-28800), complete: false, editDate: nil),
            TodoItem(context: context, name: "Make dinner", creationDate: Date().addingTimeInterval(-32400), complete: false, editDate: nil)
        ]
        .sorted { item1, item2 in
            return item1.creationDate < item2.creationDate
        }
    }
}
