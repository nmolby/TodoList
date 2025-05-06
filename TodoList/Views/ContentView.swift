//
//  ContentView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let todoItemRepository = TodoItemRepositoryImp(coreDataManager: .preview)
    
    var body: some View {
        NavigationStack {
            TodoListView(viewModel: .init(repository: todoItemRepository))
        }
    }
}

#Preview {
    ContentView()
}
