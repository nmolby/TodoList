//
//  TodoListEmptyView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import SwiftUI

struct TodoListEmptyView: View {
    @Binding var viewModel: TodoListViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No to-dos yet.")
                .font(.headline)
            
            Button("Add a To-Do") {
                viewModel.addNewTodoItem()
            }
            
            Button("Load sample To-Dos") {
                Task {
                    await viewModel.loadSampleTodos()
                }
            }
        }
    }
}

#Preview {
    TodoListEmptyView(viewModel: .constant(.init(repository: TodoItemRepository.preview, errorStore: ErrorStore(), navigationRouter: BaseAppNavigationRouter())))
}
