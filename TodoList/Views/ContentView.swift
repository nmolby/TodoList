//
//  ContentView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var todoItemRepository = TodoItemRepositoryImp(coreDataManager: .preview)
    @State var errorRepository = ErrorStoreImp()
    
    var body: some View {
        NavigationStack {
            TodoListView(viewModel: .init(repository: todoItemRepository, errorStore: errorRepository))
        }
        .overlay(alignment: .bottom) {
            if let errorString = errorRepository.errorString {
                ErrorView(errorString: errorString)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)) )
            }
        }
        .animation(.default, value: errorRepository.errorString == nil)
    }
}

#Preview {
    ContentView()
}
