//
//  ContentViewModelTests.swift
//  TodoList
//
//  Created by Nathan Molby on 5/10/25.
//

import Testing
@testable import TodoList

@MainActor struct ContentViewModelTests {
    
    @Test("ViewModel.errorString returns from error store")
    func testErrorString() {
        let sut = makeSUT()
        sut.errorStore.errorString = "Test error"
        
        #expect(sut.viewModel.errorString == "Test error")
    }
    
    @Test("Ensure repo.loadInitialItemsHelper is called on appear")
    func testHandleOnAppearHappyPath() {
        let sut = makeSUT()
        
        var loadInitialItemsCallCount = 0
        sut.repository.loadInitialItemsHelper = {
            loadInitialItemsCallCount += 1
        }
        
        sut.viewModel.handleOnAppear()
        
        #expect(sut.errorStore.errorString == nil)
        #expect(loadInitialItemsCallCount == 1)
    }
    
    @Test("Ensure loadInitialItemsHelper error is sent to errorStore")
    func testHandleOnAppearErrorPath() {
        let sut = makeSUT()
        let error = TestError.uniqueTestError(.init())
        
        sut.repository.loadInitialItemsHelper = {
            throw error
        }
        
        sut.viewModel.handleOnAppear()
        
        #expect(sut.errorStore.errorString != nil)
    }
    
    @Test("Ensure AddTodoItemViewModel has correctDependencies")
    func testAddTodoItemViewModelCreation() {
        let sut = makeSUT()
        
        let addVM = sut.viewModel.createAddTodoItemViewModel()
        
        #expect(addVM.todoItemRepository as AnyObject === sut.repository)
        #expect(addVM.errorStore as AnyObject === sut.errorStore)
    }
    
    @Test("Ensure TodoListViewModel has correctDependencies")
    func testTodoListViewModelCreation() {
        let sut = makeSUT()
        
        let listVM = sut.viewModel.createTodoListViewModel()
        
        #expect(listVM.repository as AnyObject === sut.repository)
        #expect(listVM.errorStore as AnyObject === sut.errorStore)
        // Note: This assumes your BaseAppNavigationRouter wraps NavigationRouterMock<AppRoute>
        #expect(listVM.navigationRouter as AnyObject === sut.viewModel.navigationRouter)
    }
    
    struct SUT {
        let viewModel: ContentViewModel
        let errorStore: ErrorStoreMock
        let repository: TodoItemRepositoryMock
        let router: BaseAppNavigationRouter
    }
    
    func makeSUT() -> SUT {
        let errorStore = ErrorStoreMock()
        
        let repository = TodoItemRepositoryMock()
        let router = BaseAppNavigationRouter()
        
        let viewModel = ContentViewModel(
            errorStore: errorStore,
            todoItemRepository: repository,
            navigationRouter: router
        )
        
        return SUT(viewModel: viewModel, errorStore: errorStore, repository: repository, router: router)
    }
    
}
