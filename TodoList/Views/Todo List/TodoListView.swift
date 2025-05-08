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
            case .empty:
                TodoListEmptyView(viewModel: $viewModel)
            case .loading:
                TodoListLoadingView()
            case .loaded(let items):
                List(selection: $viewModel.selectedItems) {
                    ForEach(items) { item in
                        Text(item.name)
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    toolbar
                }
                .animation(.default, value: viewModel.editMode)
            }
        }
        .task {
            await viewModel.refreshItems()
        }
        .sheet(isPresented: $viewModel.addingNewTodoItem) {
            AddTodoItemView(viewModel: viewModel.createAddNewTodoItemViewModel())
        }
        .environment(\.editMode, $viewModel.editMode)
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        if viewModel.editMode.isEditing {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteSelectedItems()
                    }
                } label: {
                    Label("Delete Selected Items", systemImage: "trash")
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(viewModel.allSelected ? "Deselect All" : "Select All") {
                    if viewModel.allSelected {
                        viewModel.deselectAll()
                    } else {
                        viewModel.selectAll()
                    }
                }
            }
        } else {
            ToolbarItem {
                Button {
                    viewModel.addNewTodoItem()
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(viewModel.editMode.isEditing ? "Done" : "Edit") {
                viewModel.toggleEditing()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        Task {
            await viewModel.deleteItems(at: offsets)
        }
    }
}

#Preview {
    TodoListView(viewModel: .init(repository: TodoItemRepositoryImp(coreDataManager: .preview), errorStore: ErrorStoreImp()))
}
