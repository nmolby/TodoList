//
//  ContentView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var dependencyStore = DependencyStoreImp()
    
    var body: some View {
        NavigationStack {
            TodoListView(viewModel: .init(repository: dependencyStore.todoItemRepository, errorStore: dependencyStore.errorStore))
        }
        .overlay(alignment: .bottom) {
            if let errorString = dependencyStore.errorStore.errorString {
                ErrorView(errorString: errorString)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)) )
            }
        }
        .animation(.default, value: dependencyStore.errorStore.errorString == nil)
        .onAppear {
            do {
                try dependencyStore.todoItemRepository.loadInitialItems()
            } catch {
                dependencyStore.errorStore.errorString = "Something went wrong loading your todos. Try again later."
            }
        }
    }
}

#Preview {
    ContentView()
}
