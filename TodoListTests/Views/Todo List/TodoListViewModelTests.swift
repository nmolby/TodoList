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
        let sut = constructSUT()
        
        #expect(sut.viewModel.viewState == .loading)
        #expect(sut.viewModel.selectedItems.isEmpty)
        #expect(sut.viewModel.editMode == .inactive)
    }
    
    // MARK: Computed Properties
    
    @Test("Tests view state happy path")
    func testViewStateHappyPath() async {
        let sut = constructSUT()
        
        #expect(sut.viewModel.viewState == .loading)
        
        sut.repository.refreshItemsHelper = { }
        
        await sut.viewModel.refreshItems()
        
        #expect(sut.viewModel.viewState == .empty)
        
        sut.repository.todoItems = mockItems()
        
        switch sut.viewModel.viewState {
        case .loaded(let items):
            #expect(Set(items.map(\.id)) == Set(mockItems().map(\.id)))
        default:
            Issue.record()
        }
    }
    
    @Test("Tests view state error on initial load")
    func testViewStateErrorPath() async {
        let sut = constructSUT()
        
        #expect(sut.viewModel.viewState == .loading)
        
        sut.repository.refreshItemsHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await sut.viewModel.refreshItems()
        
        #expect(sut.viewModel.viewState == .empty)
        
        sut.repository.todoItems = mockItems()
        
        switch sut.viewModel.viewState {
        case .loaded(let items):
            #expect(Set(items.map(\.id)) == Set(mockItems().map(\.id)))
        default:
            Issue.record()
        }
    }
    
    @Test("Tests allSelected logic works")
    func testAllSelected() async throws {
        let sut = constructSUT()
        
        let items = mockItems()
        
        sut.repository.todoItems = items
        await sut.viewModel.refreshItems()
        
        sut.viewModel.selectedItems = .init()
        
        #expect(sut.viewModel.allSelected == false)
        
        sut.viewModel.selectedItems = .init(items[0..<5].map(\.id))
        #expect(sut.viewModel.allSelected == false)
        
        sut.viewModel.selectedItems = .init(items.map(\.id))
        
        #expect(sut.viewModel.allSelected == true)
    }
    
    @Test("Tests shouldShowEditButton")
    func testShouldShowEditButton() async {
        let sut = constructSUT()
        
        #expect(sut.viewModel.shouldShowEditButton == false)
        
        sut.repository.refreshItemsHelper = { }
        
        await sut.viewModel.refreshItems()
        
        #expect(sut.viewModel.shouldShowEditButton == false)
        
        await setViewStateToLoadedWithMockItems(sut: sut)
        
        #expect(sut.viewModel.shouldShowEditButton == true)
    }
    
    // MARK: refreshItems
    @Test("Ensure refresh items calls repo refreshItems")
    func testRefreshItem() async {
        let sut = constructSUT()
        
        var refreshItemsHelperCalled = false
        
        sut.repository.refreshItemsHelper = {
            refreshItemsHelperCalled = true
        }
        
        await sut.viewModel.refreshItems()
        
        #expect(refreshItemsHelperCalled == true)
    }
    
    // MARK: refreshItems
    @Test("Ensure refreshItem error propogates to error store")
    func testRefreshItemError() async {
        let sut = constructSUT()
                
        sut.repository.refreshItemsHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await sut.viewModel.refreshItems()
        
        #expect(sut.errorStore.errorString != nil)
    }
    
    // MARK: deleteItems
    
    @Test("Ensure delete items calls repo delete items with correct items")
    func testDeleteItems_happyPath() async throws {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)

        guard case .loaded(let items) = sut.viewModel.viewState else {
            Issue.record()
            return
        }
        
        let expectedItems = items[0...5]
        var deleteTodoItemsCalled = false
                
        sut.repository.deleteTodoItemsHelper = { itemsToDelete in
            deleteTodoItemsCalled = true
            #expect(Set(expectedItems.map(\.id)) == Set(itemsToDelete.map(\.id)))
        }
        
        await sut.viewModel.deleteItems(at: .init(integersIn: 0...5))
        
        #expect(deleteTodoItemsCalled == true)
        #expect(sut.errorStore.errorString == nil)
    }
    
    @Test("Ensure delete items no-op when input is empty")
    func testDeleteItems_emptyPath() async throws {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
        
        var deleteTodoItemsCalled = false
                
        sut.repository.deleteTodoItemsHelper = { itemsToDelete in
            deleteTodoItemsCalled = true
        }
        
        await sut.viewModel.deleteItems(at: .init())
        
        #expect(deleteTodoItemsCalled == false)
    }
    
    @Test("Ensure delete items error is propogated")
    func testDeleteItems_error() async throws {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
        
        sut.repository.deleteTodoItemsHelper = { _ in
            throw TestError.uniqueTestError(.init())
        }
        
        await sut.viewModel.deleteItems(at: .init(integersIn: 0...5))
        
        #expect(sut.errorStore.errorString != nil)
    }
    
    // MARK: deleteSelectedItems
    
    @Test("Ensure delete selected items calls repo with selected items")
    func testDeleteSelectedItems_happyPath() async throws {
        let sut = constructSUT()
        
        let mockItems = await setViewStateToLoadedWithMockItems(sut: sut)
        
        let expectedItemsForDeletion = Set(mockItems[0...5])
        
        sut.viewModel.selectedItems = Set(expectedItemsForDeletion.map(\.id))
                
        var deleteTodoItemCallCount = 0
        
        sut.repository.deleteTodoItemsHelper = { deletedItems in
            deleteTodoItemCallCount += 1
            #expect(Set(deletedItems) == Set(expectedItemsForDeletion))
        }
        
        await sut.viewModel.deleteSelectedItems()
        
        #expect(deleteTodoItemCallCount == 1)
        #expect(sut.errorStore.errorString == nil)
        
    }
    
    @Test("Ensure delete selected item no-op when selection is empty")
    func testDeleteSelectedItems_emptyPath() async throws {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
        
        sut.viewModel.selectedItems = Set()
                        
        sut.repository.deleteTodoItemsHelper = { deletedItems in
            Issue.record()
        }
        
        await sut.viewModel.deleteSelectedItems()
    }
    
    @Test("Ensure delete selected items error is propogated")
    func testDeleteSelectedItems_error() async {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
                
        sut.viewModel.selectedItems = Set(mockItems()[0...5].map(\.id))
                        
        sut.repository.deleteTodoItemsHelper = { deletedItems in
            throw TestError.uniqueTestError(.init())
        }
        
        await sut.viewModel.deleteSelectedItems()
        
        #expect(sut.errorStore.errorString != nil)
    }
    
    @Test("Ensure load sample todos calls repo")
    func testLoadSampleTodos() async  {
        let sut = constructSUT()
                
        var loadSampleTodosCallCount: Int = 0
        
        sut.repository.loadSampleTodosHelper = {
            loadSampleTodosCallCount += 1
        }
        
        await sut.viewModel.loadSampleTodos()
        
        #expect(loadSampleTodosCallCount == 1)
        #expect(sut.errorStore.errorString == nil)
    }
    
    @Test("Ensure load sample todos errors is sent to error store")
    func testLoadSampleTodos_error() async  {
        let sut = constructSUT()
                        
        sut.repository.loadSampleTodosHelper = {
            throw TestError.uniqueTestError(.init())
        }
        
        await sut.viewModel.loadSampleTodos()
        
        #expect(sut.errorStore.errorString != nil)
    }

    // MARK: toggleEditing
    @Test("Ensure toggle editing toggles editMode and clears selectedItems")
    func testToggleEditing() {
        let sut = constructSUT()
        
        sut.viewModel.editMode = .inactive
        
        sut.viewModel.toggleEditing()
        
        #expect(sut.viewModel.editMode == .active)
        
        sut.viewModel.selectedItems = .init(mockItems().map(\.id))
        
        sut.viewModel.toggleEditing()
        
        #expect(sut.viewModel.editMode == .inactive)
        #expect(sut.viewModel.selectedItems.isEmpty)
    }
    
    // MARK: Select All
    @Test("Ensure select all selects all items")
    func testSelectAll() async {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
                
        sut.viewModel.selectAll()
        
        #expect(sut.viewModel.selectedItems == Set(mockItems().map(\.id)))
    }
    
    // MARK: Deselect All
    @Test("Ensure deselect all deselects all items")
    func testDeselectAll() async {
        let sut = constructSUT()
        
        await setViewStateToLoadedWithMockItems(sut: sut)
        
        sut.viewModel.selectedItems = Set(mockItems().map(\.id))
        
        sut.viewModel.deselectAll()
        
        #expect(sut.viewModel.selectedItems.isEmpty)
    }
    
    // MARK: addNewTodoItem
    @Test("Ensure addNewTodoItem adds addTodo to nav router")
    func testAddNewTodoItem() async {
        let sut = constructSUT()
        
        sut.viewModel.addNewTodoItem()
        
        #expect(sut.navigationRouter.navigatedRoute == BaseAppNavigationRoute.addTodo)
    }
    
    @discardableResult private func setViewStateToLoadedWithMockItems(sut: SUT) async -> [TodoItem] {
        let items = mockItems()
        
        sut.repository.refreshItemsHelper = { }
        sut.repository.todoItems = items
        
        await sut.viewModel.refreshItems()
        
        return items
    }
    
    private func constructSUT() -> SUT {
        let mockRepository = TodoItemRepositoryMock()
        let mockErrorStore = ErrorStoreMock()
        let mockNavigationRouter = NavigationRouterMock<BaseAppNavigationRoute>()
        
        let viewModel = TodoListViewModel(repository: mockRepository, errorStore: mockErrorStore, navigationRouter: mockNavigationRouter)
        
        return .init(viewModel: viewModel, repository: mockRepository, errorStore: mockErrorStore, navigationRouter: mockNavigationRouter)
    }
    
    private struct SUT {
        var viewModel: TodoListViewModel
        var repository: TodoItemRepositoryMock
        var errorStore: ErrorStoreMock
        var navigationRouter: NavigationRouterMock<BaseAppNavigationRoute>
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
