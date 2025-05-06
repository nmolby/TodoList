//
//  TodoListView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import SwiftUI

struct TodoListView: View {
    @State var viewModel: TodoListViewModel
    
    init(viewModel: TodoListViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .loaded(let items):
                List(selection: $viewModel.selectedItems) {
                    ForEach(items) { item in
                        Text(item.name)
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    if viewModel.editMode.isEditing {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(role: .destructive) {
                                handleDeleteSelectedItems()
                            } label: {
                                Label("Delete Selected Items", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            Button(viewModel.allSelected ? "Unselect All" : "Select All") {
                                if viewModel.allSelected {
                                    viewModel.unselectAll()
                                } else {
                                    viewModel.selectAll()
                                }
                            }
                        }
                    } else {
                        ToolbarItem {
                            Button(action: {}) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(viewModel.editMode.isEditing ? "Done" : "Edit") {
                            withAnimation {
                                viewModel.editMode = viewModel.editMode.isEditing ? .inactive : .active
                            }
                        }
                    }
                    
                }
            case .error(let error):
                Text("Something went wrong.")
            }
        }
        .task {
            await viewModel.loadTodoItems()
        }
        .environment(\.editMode, $viewModel.editMode)
    }
    
    private func handleDeleteSelectedItems() {
        Task {
            do {
                try await viewModel.onDeleteSelectedItems()
            } catch {
                // TODO: handle error
            }
        }
    }
    
    private func handleDeleteAllItems() {
        Task {
            do {
                try await viewModel.onDeleteSelectedItems()
            } catch {
                // TODO: handle error
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        guard case .loaded(let items) = viewModel.viewState else { return }
        
        withAnimation {
            let items = offsets.map { items[$0] }
            
            Task {
                do {
                    try await viewModel.onDelete(items: items)
                } catch {
                    // TODO: propogate error to view
                }
            }
        }
    }
}

#Preview {
    TodoListView(viewModel: .init(repository: TodoItemRepositoryImp(coreDataManager: .preview)))
}
