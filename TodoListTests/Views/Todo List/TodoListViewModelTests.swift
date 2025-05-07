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
    
    // MARK: Computed Properties
    @Test func testAllSelected() async throws {
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
    @Test("Ensure loadTodoItems success leads to view state loaded") func testLoadTodoItems_happyPath() async {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let mockItems = mockItems(context: coreDataManager.container.viewContext)
        
        var repoCallCount = 0
        mockRepo.getTodoItemsHelper = {
            repoCallCount += 1
            return mockItems
        }
        
        await viewModel.loadTodoItems()
        
        #expect(repoCallCount == 1)
        
        let expectedItems = mockItems
        
        #expect(viewModel.viewState == .loaded(items: expectedItems))
        
        let itemsIncorrectlySorted = mockItems.sorted { item1, item2 in
            return item1.creationDate > item2.creationDate
        }
        
        #expect(viewModel.viewState != .loaded(items: itemsIncorrectlySorted))
    }
    
    @Test("Ensure loadTodoItems error leads to view state error") func testLoadTodoItems_errorPath() async {
        let (viewModel, mockRepo, _) = constructSUT()
        
        let expectedError = TestError.uniqueTestError(.init())
        
        var repoCallCount = 0
        mockRepo.getTodoItemsHelper = {
            repoCallCount += 1
            throw expectedError
        }
        
        await viewModel.loadTodoItems()
        
        #expect(repoCallCount == 1)
        #expect(viewModel.viewState == .error(expectedError))
    }
    
    // MARK: deleteItems
    
    @Test("Ensure delete items deletes correct items and re-fetches") func testDeleteItems_happyPath() async throws {
        let (viewModel, mockRepo, coreDataManager) = constructSUT()
        
        let allItems = mockItems(context: coreDataManager.container.viewContext)
        let itemsAfterDeletions = Array(allItems[0..<5])
        let itemsToBeDeleted = Array(allItems[5...])
        
        var getItemsCallCount = 0
        var deleteItemsCallCount = 0
        
        mockRepo.getTodoItemsHelper = {
            defer {
                getItemsCallCount += 1
            }
            
            if getItemsCallCount == 0 {
                return allItems
            } else {
                return itemsAfterDeletions
            }
        }
        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            #expect(Set(deletedItems) == Set(itemsToBeDeleted))
            deleteItemsCallCount += 1
        }
        
        await viewModel.loadTodoItems()
        try await viewModel.deleteItems(at: .init(integersIn: 5..<allItems.endIndex))
        
        #expect(getItemsCallCount == 2)
        #expect(deleteItemsCallCount == 1)
        
        #expect(viewModel.viewState == .loaded(items: itemsAfterDeletions))
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
