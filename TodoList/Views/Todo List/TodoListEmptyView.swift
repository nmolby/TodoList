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
                viewModel.addingNewTodoItem = true
            }
            
            Button("Load sample To-Dos") {
                
            }
        }
    }
}

#Preview {
    TodoListEmptyView(viewModel: .constant(.init(repository: TodoItemRepositoryImp(coreDataManager: .preview), errorStore: ErrorStoreImp())))
}
