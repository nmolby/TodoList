//
//  TodoListViewState.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

enum TodoListViewState {
    case loading
    case loaded(items: [TodoItem])
    case error(_ error: Error)
}
