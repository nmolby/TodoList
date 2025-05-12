//
//  TodoItemDTOTests.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/11/25.
//

import Testing
@testable import TodoList
import Foundation

struct TodoItemDTOTests {

    @Test func testToTodoItem() async throws {
        let dto = TodoItemDTO(userId: 0, id: 5000, title: "Test Todo", completed: false)
        let convertedDto = dto.toTodoItem()
        
        #expect(convertedDto.id == "5000")
        #expect(convertedDto.name == "Test Todo")
        
        // In a prod app, I would inject Date.now functionality so we can test it more precisely
        #expect(convertedDto.creationDate < Date.now)
        #expect(convertedDto.creationDate > Date.now.addingTimeInterval(-1))
    }

}
