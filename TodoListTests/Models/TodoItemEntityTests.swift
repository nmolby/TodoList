//
//  TodoItemEntityTests.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/11/25.
//

import Testing
@testable import TodoList
import Foundation

struct TodoItemEntityTests {

    @Test func testToTodoItem() async throws {
        let sut = makeSUT()
        let context = sut.container.viewContext
        let expectedCreationDate = Date.now
        let entity = TodoItemEntity(context: context, name: "Test Todo", id: "121234", creationDate: expectedCreationDate)
        let convertedEntity = entity.toTodoItem()
        
        #expect(convertedEntity.id == "121234")
        #expect(convertedEntity.name == "Test Todo")
        #expect(convertedEntity.creationDate == expectedCreationDate)
    }
    
    private func makeSUT() -> CoreDataManager {
        return CoreDataManager(inMemory: true)
    }
}
