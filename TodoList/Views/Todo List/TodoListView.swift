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
                    .onDelete(perform: viewModel.editMode.isEditing ? deleteItems : deleteItems)
                }
                .toolbar {
                    toolbar
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
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        if viewModel.editMode.isEditing {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    deleteSelectedItems()
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
                Button(action: {}) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(viewModel.editMode.isEditing ? "Done" : "Edit") {
                withAnimation {
                    viewModel.toggleEditing()
                }
            }
        }
        
    }
    
    private func deleteSelectedItems() {
        Task {
            do {
                try await viewModel.deleteSelectedItems()
            } catch {
                // TODO: handle error
            }
        }
    }
    
    private func deleteAllItems() {
        Task {
            do {
                try await viewModel.deleteSelectedItems()
            } catch {
                // TODO: handle error
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        Task {
            do {
                try await viewModel.deleteItems(at: offsets)
            } catch {
                // TODO: handle error
            }
        }
    }
}

#Preview {
    TodoListView(viewModel: .init(repository: TodoItemRepositoryImp(coreDataManager: .preview)))
}
