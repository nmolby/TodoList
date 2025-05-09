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
        #expect(viewModel.addingNewTodoItem == false)
    }
    
    // MARK: Computed Properties
    
    @Test("Tests view state happy path")
    func testViewStateHappyPath() async {
        let (viewModel, repository, _) = constructSUT()
        
        #expect(viewModel.viewState == .loading)
        
        repository.refreshItemsHelper = { }
        
        await viewModel.refreshItems()
        
        #expect(viewModel.viewState == .empty)
        
        repository.todoItems = mockItems()
        
        switch viewModel.viewState {
        case .loaded(let items):
            #expect(Set(items.map(\.id)) == Set(mockItems().map(\.id)))
        default:
            Issue.record()
        }
    }
    
    @Test("Tests view state error on initial load")
    func testViewStateErrorPath() async {
        let (viewModel, repository, _) = constructSUT()
        
        #expect(viewModel.viewState == .loading)
        
        repository.refreshItemsHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await viewModel.refreshItems()
        
        #expect(viewModel.viewState == .empty)
        
        repository.todoItems = mockItems()
        
        switch viewModel.viewState {
        case .loaded(let items):
            #expect(Set(items.map(\.id)) == Set(mockItems().map(\.id)))
        default:
            Issue.record()
        }
    }
    
    @Test("Tests allSelected logic works")
    func testAllSelected() async throws {
        let (viewModel, repository, _) = constructSUT()
        
        let items = mockItems()
        
        repository.todoItems = items
        await viewModel.refreshItems()
        
        viewModel.selectedItems = .init()
        
        #expect(viewModel.allSelected == false)
        
        viewModel.selectedItems = .init(items[0..<5].map(\.id))
        #expect(viewModel.allSelected == false)
        
        viewModel.selectedItems = .init(items.map(\.id))
        
        #expect(viewModel.allSelected == true)
    }
    
    @Test("Tests shouldShowEditButton")
    func testShouldShowEditButton() async {
        let (viewModel, repository, _) = constructSUT()
        
        #expect(viewModel.shouldShowEditButton == false)
        
        repository.refreshItemsHelper = { }
        
        await viewModel.refreshItems()
        
        #expect(viewModel.shouldShowEditButton == false)
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: repository)
        
        #expect(viewModel.shouldShowEditButton == true)
    }
    
    // MARK: refreshItems
    @Test("Ensure refresh items calls repo refreshItems")
    func testRefreshItem() async {
        let (viewModel, repository, _) = constructSUT()
        
        var refreshItemsHelperCalled = false
        
        repository.refreshItemsHelper = {
            refreshItemsHelperCalled = true
        }
        
        await viewModel.refreshItems()
        
        #expect(refreshItemsHelperCalled == true)
    }
    
    // MARK: refreshItems
    @Test("Ensure refreshItem error propogates to error store")
    func testRefreshItemError() async {
        let (viewModel, repository, errorStore) = constructSUT()
                
        repository.refreshItemsHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await viewModel.refreshItems()
        
        #expect(errorStore.errorString != nil)
    }
    
    // MARK: deleteItems
    
    @Test("Ensure delete items calls repo delete items with correct items")
    func testDeleteItems_happyPath() async throws {
        let (viewModel, mockRepo, errorStore) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)

        guard case .loaded(let items) = viewModel.viewState else {
            Issue.record()
            return
        }
        
        let expectedItems = items[0...5]
        var deleteTodoItemsCalled = false
                
        mockRepo.deleteTodoItemsHelper = { itemsToDelete in
            deleteTodoItemsCalled = true
            #expect(Set(expectedItems.map(\.id)) == Set(itemsToDelete.map(\.id)))
        }
        
        await viewModel.deleteItems(at: .init(integersIn: 0...5))
        
        #expect(deleteTodoItemsCalled == true)
        #expect(errorStore.errorString == nil)
    }
    
    @Test("Ensure delete items no-op when input is empty")
    func testDeleteItems_emptyPath() async throws {
        let (viewModel, mockRepo, _) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
        
        var deleteTodoItemsCalled = false
                
        mockRepo.deleteTodoItemsHelper = { itemsToDelete in
            deleteTodoItemsCalled = true
        }
        
        await viewModel.deleteItems(at: .init())
        
        #expect(deleteTodoItemsCalled == false)
    }
    
    @Test("Ensure delete items error is propogated")
    func testDeleteItems_error() async throws {
        let (viewModel, mockRepo, errorStore) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
        
        mockRepo.deleteTodoItemsHelper = { _ in
            throw TestError.uniqueTestError(.init())
        }
        
        await viewModel.deleteItems(at: .init(integersIn: 0...5))
        
        #expect(errorStore.errorString != nil)
    }
    
    // MARK: deleteSelectedItems
    
    @Test("Ensure delete selected items calls repo with selected items")
    func testDeleteSelectedItems_happyPath() async throws {
        let (viewModel, mockRepo, errorStore) = constructSUT()
        
        let mockItems = await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
        
        let expectedItemsForDeletion = Set(mockItems[0...5])
        
        viewModel.selectedItems = Set(expectedItemsForDeletion.map(\.id))
                
        var deleteTodoItemCallCount = 0
        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            deleteTodoItemCallCount += 1
            #expect(Set(deletedItems) == Set(expectedItemsForDeletion))
        }
        
        await viewModel.deleteSelectedItems()
        
        #expect(deleteTodoItemCallCount == 1)
        #expect(errorStore.errorString == nil)
        
    }
    
    @Test("Ensure delete selected item no-op when selection is empty")
    func testDeleteSelectedItems_emptyPath() async throws {
        let (viewModel, mockRepo, _) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
        
        viewModel.selectedItems = Set()
                        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            Issue.record()
        }
        
        await viewModel.deleteSelectedItems()
    }
    
    @Test("Ensure delete selected items error is propogated")
    func testDeleteSelectedItems_error() async {
        let (viewModel, mockRepo, errorStore) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
                
        viewModel.selectedItems = Set(mockItems()[0...5].map(\.id))
                        
        mockRepo.deleteTodoItemsHelper = { deletedItems in
            throw TestError.uniqueTestError(.init())
        }
        
        await viewModel.deleteSelectedItems()
        
        #expect(errorStore.errorString != nil)
    }
    
    @Test("Ensure load sample todos calls repo")
    func testLoadSampleTodos() async  {
        let (viewModel, mockRepo, errorStore) = constructSUT()
                
        var loadSampleTodosCallCount: Int = 0
        
        mockRepo.loadSampleTodosHelper = {
            loadSampleTodosCallCount += 1
        }
        
        await viewModel.loadSampleTodos()
        
        #expect(loadSampleTodosCallCount == 1)
        #expect(errorStore.errorString == nil)
    }
    
    @Test("Ensure load sample todos errors is sent to error store")
    func testLoadSampleTodos_error() async  {
        let (viewModel, mockRepo, errorStore) = constructSUT()
                        
        mockRepo.loadSampleTodosHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await viewModel.loadSampleTodos()
        
        #expect(errorStore.errorString != nil)
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
    func testSelectAll() async {
        let (viewModel, mockRepo, _) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
                
        viewModel.selectAll()
        
        #expect(viewModel.selectedItems == Set(mockItems().map(\.id)))
    }
    
    // MARK: Deselect All
    @Test("Ensure deselect all deselects all items")
    func testDeselectAll() async {
        let (viewModel, mockRepo, _) = constructSUT()
        
        await setViewStateToLoadedWithMockItems(viewModel: viewModel, repo: mockRepo)
        
        viewModel.selectedItems = Set(mockItems().map(\.id))
        
        viewModel.deselectAll()
        
        #expect(viewModel.selectedItems.isEmpty)
    }
    
    // MARK: addNewTodoItem
    @Test("Ensure addNewTodoItem sets addingNewTodoItem to true")
    func testAddNewTodoItem() async {
        let (viewModel, _, _) = constructSUT()
        
        viewModel.addNewTodoItem()
        
        #expect(viewModel.addingNewTodoItem == true)
    }
    
    // MARK: createAddNewTodoItemViewModel
    @Test("Ensure createAddNewTodoItemViewModel uses correct references")
    func testCreateAddNewTodoItemViewModel() {
        let (viewModel, mockRepo, errorStore) = constructSUT()
        
        let createAddNewTodoItemViewModel = viewModel.createAddNewTodoItemViewModel()
        
        guard let errorStoreInViewModel = (createAddNewTodoItemViewModel.errorStore as? ErrorStoreMock), let repoInViewModel = (createAddNewTodoItemViewModel.todoItemRepository as? TodoItemRepositoryMock) else {
            Issue.record()
            return
        }
        
        #expect(errorStoreInViewModel === errorStore)
        #expect(repoInViewModel === mockRepo)
    }
    
    @discardableResult private func setViewStateToLoadedWithMockItems(viewModel: TodoListViewModel, repo: TodoItemRepositoryMock) async -> [TodoItem] {
        let items = mockItems()
        
        repo.refreshItemsHelper = { }
        repo.todoItems = items
        
        await viewModel.refreshItems()
        
        return items
    }
    
    private func constructSUT() ->  (TodoListViewModel, TodoItemRepositoryMock, ErrorStoreMock) {
        let mockRepository = TodoItemRepositoryMock()
        let mockErrorStore = ErrorStoreMock()
        
        let viewModel = TodoListViewModel(repository: mockRepository, errorStore: mockErrorStore)
        
        return (viewModel, mockRepository, mockErrorStore)
    }
    
}

extension TodoListViewModelTests {
    private func mockItems() -> [TodoItem] {
        return [
            TodoItem(name: "Feed the dog", id: "1", creationDate: Date(), editDate: nil),
            TodoItem(name: "Take out trash", id: "2", creationDate: Date().addingTimeInterval(-3600), editDate: Date().addingTimeInterval(-1800)),
            TodoItem(name: "Read Bible", id: "3", creationDate: Date().addingTimeInterval(-7200), editDate: nil),
            TodoItem(name: "Water plants", id: "4", creationDate: Date().addingTimeInterval(-10800), editDate: Date().addingTimeInterval(-9000)),
            TodoItem(name: "Reply to email", id: "5", creationDate: Date().addingTimeInterval(-14400), editDate: nil),
            TodoItem(name: "Buy groceries", id: "6", creationDate: Date().addingTimeInterval(-18000), editDate: Date().addingTimeInterval(-10000)),
            TodoItem(name: "Call Mom", id: "7", creationDate: Date().addingTimeInterval(-21600), editDate: nil),
            TodoItem(name: "Go for a walk", id: "8", creationDate: Date().addingTimeInterval(-25200), editDate: Date().addingTimeInterval(-20000)),
            TodoItem(name: "Check mailbox", id: "9", creationDate: Date().addingTimeInterval(-28800), editDate: nil),
            TodoItem(name: "Make dinner", id: "10", creationDate: Date().addingTimeInterval(-32400), editDate: nil)
        ]
        .sorted { item1, item2 in
            return item1.creationDate < item2.creationDate
        }
    }
}
