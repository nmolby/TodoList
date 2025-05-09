//
//  Dependency Store.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

protocol DependencyStore {
    var errorStore: any ErrorStore { get }
    var todoItemRepository: any TodoItemRepository { get }
}
