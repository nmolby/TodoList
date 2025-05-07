//
//  TodoListViewState.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

enum TodoListViewState: Equatable {
    
    case loading
    case loaded(items: [TodoItem])
    case error(_ error: Error)
    
    static func == (lhs: TodoListViewState, rhs: TodoListViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let items1), .loaded(let items2)):
            return items1 == items2
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}
