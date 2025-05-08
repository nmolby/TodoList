//
//  TodoItemDTO.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

struct TodoItemDTO: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

extension TodoItemDTO {
    func toTodoItem() -> TodoItem {
        return .init(name: title, id: String(id), creationDate: .now, editDate: nil)
    }
}
