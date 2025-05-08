//
//  TodoListViewState.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import Foundation

enum TodoListViewState: Equatable {
    case loading
    case empty
    case loaded(items: [TodoItem])
    
}
