//
//  AddTodoItemView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import SwiftUI

struct AddTodoItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: AddTodoItemViewModel
    
    init(viewModel: AddTodoItemViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("To-Do")) {
                    TextField("Enter to-do name", text: $viewModel.name)
                        .autocapitalization(.sentences)
                        .disableAutocorrection(false)
                }
            }
            .navigationTitle("New To-Do")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.submitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                try await viewModel.save()
                                
                                dismiss()
                            }
                        }
                        .disabled(viewModel.name.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    AddTodoItemView(viewModel: .init(todoItemRepository: TodoItemRepository(coreDataManager: .preview, apiClient: APIClient(baseURL: .init(string: "https://jsonplaceholder.typicode.com")!)), errorStore: ErrorStore()))
}
