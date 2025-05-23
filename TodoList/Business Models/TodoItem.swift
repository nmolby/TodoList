//
//  TodoItem.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import Foundation

struct TodoItem: Identifiable, Equatable, Hashable {
    let name: String
    let id: String
    let creationDate: Date
    
    init(name: String, id: String = UUID().uuidString, creationDate: Date = .now) {
        self.name = name
        self.id = id
        self.creationDate = creationDate
    }
}
