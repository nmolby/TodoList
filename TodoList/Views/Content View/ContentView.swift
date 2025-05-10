//
//  ContentView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @State var viewModel = ContentViewModel(
        errorStore: ErrorStore(),
        todoItemRepository: TodoItemRepository(
            coreDataManager: CoreDataManager(),
            apiClient: APIClient(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
            )
        ),
        navigationRouter: BaseAppNavigationRouter()
    )
    
    var body: some View {
        NavigationStack {
            TodoListView(viewModel: viewModel.createTodoListViewModel())
        }
        .overlay(alignment: .bottom) {
            if let errorString = viewModel.errorString {
                ErrorView(errorString: errorString)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)) )
            }
        }
        .sheet(item: $viewModel.navigationRouter.sheetDisplayed) { sheet in
            switch sheet {
            case .addTodo:
                AddTodoItemView(viewModel: viewModel.createAddTodoItemViewModel())
            }
        }
        .animation(.default, value: viewModel.errorStore.errorString == nil)
        .onAppear {
            viewModel.handleOnAppear()
        }
    }
}

#Preview {
    ContentView()
}
